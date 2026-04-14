"""
TourSup — Veri Hazırlama Scripti
=================================
Kullanım:
    python data_prep.py --source kaggle          # Yalnızca Kaggle veri setleri
    python data_prep.py --source google          # Yalnızca Google Landmarks v2
    python data_prep.py --source all             # Her iki kaynak (varsayılan)
    python data_prep.py --source all --verify    # Hazırlandıktan sonra özet göster

Gereksinimler:
    - Kaggle API anahtarı: ~/.kaggle/kaggle.json
    - pip install -r requirements.txt
"""

import argparse
import json
import os
import shutil
import zipfile
from pathlib import Path

import pandas as pd
import requests
from PIL import Image
from tqdm import tqdm

from config import (
    CLASS_MAP_PATH,
    DATA_DIR,
    GOOGLE_LANDMARKS_IDS,
    IMAGE_SIZE,
    LANDMARK_CLASSES,
    MIN_IMAGES_PER_CLASS,
    PROCESSED_DIR,
)

# ---------------------------------------------------------------------------
# Yardımcı fonksiyonlar
# ---------------------------------------------------------------------------

def make_dirs():
    """Her landmark sınıfı için raw ve processed klasörlerini oluşturur."""
    for cls in LANDMARK_CLASSES:
        Path(DATA_DIR, cls).mkdir(parents=True, exist_ok=True)
        Path(PROCESSED_DIR, cls).mkdir(parents=True, exist_ok=True)
    print(f"[✓] Klasör yapısı hazır: {len(LANDMARK_CLASSES)} sınıf")


def resize_and_save(src_path: Path, dst_path: Path) -> bool:
    """Görüntüyü IMAGE_SIZE x IMAGE_SIZE boyutuna getirip kaydeder."""
    try:
        with Image.open(src_path) as im:
            im = im.convert("RGB")
            im = im.resize((IMAGE_SIZE, IMAGE_SIZE), Image.LANCZOS)
            im.save(dst_path, "JPEG", quality=90)
        return True
    except Exception as e:
        print(f"  [!] Atlandı {src_path.name}: {e}")
        return False


# ---------------------------------------------------------------------------
# Kaggle veri setleri
# ---------------------------------------------------------------------------

KAGGLE_DATASETS = [
    # (Kaggle kullanıcı/dataset-adı, indirme klasörü)
    ("ouzcanmaden/places-to-visit-in-istanbul",  "kaggle_istanbul"),
    ("egeucak/landmark-places-of-turkey",        "kaggle_turkey"),
    ("ziya07/tourism-landmark-dataset",          "kaggle_tourism"),
]

# Her Kaggle veri setindeki alt klasör adı → landmark sınıfı eşlemesi
KAGGLE_FOLDER_MAP = {
    # İstanbul veri seti
    "hagia_sophia":   ["hagia_sophia", "ayasofya"],
    "blue_mosque":    ["blue_mosque",  "sultanahmet"],
    "topkapi":        ["topkapi",      "topkapi_palace"],
    "galata_tower":   ["galata",       "galata_tower"],
    "dolmabahce":     ["dolmabahce",   "dolmabahce_palace"],
    # Türkiye veri seti
    "ephesus":        ["ephesus",      "efes"],
    "cappadocia":     ["cappadocia",   "kapadokya"],
    "pamukkale":      ["pamukkale"],
    "nemrut":         ["nemrut"],
    "gobekli_tepe":   ["gobekli_tepe", "gobeklitepe"],
    "konya_mevlana":  ["mevlana",      "konya"],
    "selimiye":       ["selimiye"],
    "pergamon":       ["pergamon",     "bergama"],
}


def download_kaggle_datasets(raw_dir: str = "data/kaggle_raw"):
    """Kaggle API ile veri setlerini indirir ve zip'leri açar."""
    try:
        import kaggle  # noqa: F401
    except ImportError:
        print("[!] kaggle paketi yüklü değil: pip install kaggle")
        return

    Path(raw_dir).mkdir(parents=True, exist_ok=True)

    for dataset_id, folder_name in KAGGLE_DATASETS:
        dest = Path(raw_dir, folder_name)
        if dest.exists():
            print(f"[~] Zaten indirilmiş: {dataset_id}")
            continue
        print(f"[↓] İndiriliyor: {dataset_id}")
        os.system(
            f'kaggle datasets download -d "{dataset_id}" -p "{dest}" --unzip'
        )
        print(f"[✓] Tamamlandı: {folder_name}")


def copy_kaggle_images(raw_dir: str = "data/kaggle_raw"):
    """
    Açılmış Kaggle klasörlerini tarar; KAGGLE_FOLDER_MAP'e göre
    görüntüleri DATA_DIR/<sınıf>/ altına kopyalar.
    """
    copied = 0
    skipped = 0

    for cls, folder_aliases in KAGGLE_FOLDER_MAP.items():
        dst_dir = Path(DATA_DIR, cls)

        for _, folder_name in KAGGLE_DATASETS:
            dataset_path = Path(raw_dir, folder_name)
            if not dataset_path.exists():
                continue

            # Alt klasörlerde alias adını ara
            for alias in folder_aliases:
                for candidate in dataset_path.rglob(f"*{alias}*"):
                    if not candidate.is_dir():
                        continue
                    for img_path in candidate.rglob("*"):
                        if img_path.suffix.lower() not in {".jpg", ".jpeg", ".png", ".webp"}:
                            continue
                        dst = dst_dir / img_path.name
                        if dst.exists():
                            skipped += 1
                            continue
                        shutil.copy2(img_path, dst)
                        copied += 1

    print(f"[✓] Kaggle: {copied} görüntü kopyalandı, {skipped} atlandı")


# ---------------------------------------------------------------------------
# Google Landmarks v2
# ---------------------------------------------------------------------------

def download_google_landmarks(
    csv_url: str = (
        "https://s3.amazonaws.com/google-landmark/metadata/"
        "train_label_to_category.csv"
    ),
    index_url: str = (
        "https://s3.amazonaws.com/google-landmark/metadata/"
        "train.csv"
    ),
    raw_dir: str = "data/google_raw",
    max_per_class: int = 300,
):
    """
    Google Landmarks v2 meta-CSV'lerini indirir; GOOGLE_LANDMARKS_IDS listesindeki
    yapılara ait görüntü URL'lerini çekerek raw klasörüne kaydeder.

    Tam veri seti (500 GB) indirmek yerine yalnızca hedef sınıf görüntüleri indirilir.
    """
    Path(raw_dir).mkdir(parents=True, exist_ok=True)

    # 1) landmark id → label eşlemesini indir
    cat_csv = Path(raw_dir, "train_label_to_category.csv")
    if not cat_csv.exists():
        print("[↓] train_label_to_category.csv indiriliyor...")
        _download_file(csv_url, cat_csv)

    # 2) train index'i indir (URL + landmark_id sütunları)
    train_csv = Path(raw_dir, "train.csv")
    if not train_csv.exists():
        print("[↓] train.csv indiriliyor (~750 MB, biraz zaman alabilir)...")
        _download_file(index_url, train_csv)

    print("[↓] train.csv okunuyor...")
    df = pd.read_csv(train_csv)  # id, url, landmark_id

    for cls, gl_ids in GOOGLE_LANDMARKS_IDS.items():
        dst_dir = Path(DATA_DIR, cls)
        existing = len(list(dst_dir.glob("*.jpg")))
        needed = max(0, max_per_class - existing)
        if needed == 0:
            print(f"[~] {cls}: zaten yeterli görüntü var ({existing})")
            continue

        subset = df[df["landmark_id"].astype(str).isin(gl_ids)].head(needed)
        print(f"[↓] {cls}: {len(subset)} görüntü indiriliyor...")

        for _, row in tqdm(subset.iterrows(), total=len(subset), desc=cls):
            img_id = row["id"]
            url = row["url"]
            dst = dst_dir / f"glv2_{img_id}.jpg"
            if dst.exists():
                continue
            try:
                resp = requests.get(url, timeout=10)
                if resp.status_code == 200:
                    dst.write_bytes(resp.content)
            except Exception:
                pass  # Ağ hatalarında geç, diğerlerine devam et


def _download_file(url: str, dest: Path):
    resp = requests.get(url, stream=True, timeout=60)
    resp.raise_for_status()
    total = int(resp.headers.get("content-length", 0))
    with open(dest, "wb") as f, tqdm(total=total, unit="B", unit_scale=True) as bar:
        for chunk in resp.iter_content(chunk_size=8192):
            f.write(chunk)
            bar.update(len(chunk))


# ---------------------------------------------------------------------------
# İşleme: yeniden boyutlandırma + doğrulama
# ---------------------------------------------------------------------------

def process_all():
    """
    DATA_DIR altındaki tüm ham görüntüleri IMAGE_SIZE x IMAGE_SIZE
    boyutuna getirip PROCESSED_DIR altına kaydeder.
    """
    total_ok = 0
    total_fail = 0

    for cls in LANDMARK_CLASSES:
        src_dir = Path(DATA_DIR, cls)
        dst_dir = Path(PROCESSED_DIR, cls)

        images = list(src_dir.glob("*"))
        images = [p for p in images if p.suffix.lower() in {".jpg", ".jpeg", ".png", ".webp"}]

        for img_path in tqdm(images, desc=f"İşleniyor: {cls}", leave=False):
            dst = dst_dir / (img_path.stem + ".jpg")
            if dst.exists():
                total_ok += 1
                continue
            if resize_and_save(img_path, dst):
                total_ok += 1
            else:
                total_fail += 1

    print(f"\n[✓] İşleme tamamlandı — başarılı: {total_ok}, başarısız: {total_fail}")


def verify():
    """Her sınıftaki görüntü sayısını tablo halinde gösterir."""
    print(f"\n{'Sınıf':<35} {'Ham':>6} {'İşlenmiş':>10} {'Durum':>10}")
    print("-" * 65)

    with open(CLASS_MAP_PATH) as f:
        class_map = json.load(f)
    id_to_name = {v: k for k, v in class_map.items()}  # id → index

    for cls in LANDMARK_CLASSES:
        raw_count = len(list(Path(DATA_DIR, cls).glob("*.jpg")))
        proc_count = len(list(Path(PROCESSED_DIR, cls).glob("*.jpg")))
        status = "✓" if proc_count >= MIN_IMAGES_PER_CLASS else "⚠ AZ"
        display = cls[:33]
        print(f"{display:<35} {raw_count:>6} {proc_count:>10} {status:>10}")


# ---------------------------------------------------------------------------
# Ana giriş noktası
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="TourSup veri hazırlama")
    parser.add_argument(
        "--source",
        choices=["kaggle", "google", "all"],
        default="all",
        help="Veri kaynağı (varsayılan: all)",
    )
    parser.add_argument(
        "--verify",
        action="store_true",
        help="Hazırlandıktan sonra sınıf başına görüntü sayısını göster",
    )
    args = parser.parse_args()

    make_dirs()

    if args.source in ("kaggle", "all"):
        download_kaggle_datasets()
        copy_kaggle_images()

    if args.source in ("google", "all"):
        download_google_landmarks()

    print("\n[→] Görüntüler işleniyor...")
    process_all()

    if args.verify:
        verify()

    print("\n[✓] Veri hazırlama tamamlandı.")
    print(f"    İşlenmiş veri: {PROCESSED_DIR}/")
    print("    Sonraki adım : python train.py")
