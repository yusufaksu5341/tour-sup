"""
TourSup — TFLite Export ve Kuantizasyon Scripti
================================================
Kullanım:
    python export_tflite.py                          # Float16 kuantizasyon (varsayılan)
    python export_tflite.py --quant int8             # INT8 tam kuantizasyon
    python export_tflite.py --quant none             # Kuantizasyon yok (float32)
    python export_tflite.py --model models/last.keras  # Farklı checkpoint

Çıktı:
    ../assets/models/landmark_efficientnet.tflite   — Flutter asset klasörüne direkt kopyalar
    models/landmark_efficientnet_<quant>.tflite     — Yedek kopya

Boyut beklentisi:
    float32  → ~20 MB
    float16  → ~10 MB   ← Önerilen (kalite/boyut dengesi)
    int8     →  ~5 MB   ← En küçük, mobil için ideal
"""

import argparse
import json
import shutil
import time
from pathlib import Path

import numpy as np
import tensorflow as tf
from tensorflow import keras

from config import (
    IMAGE_SIZE,
    LANDMARK_CLASSES,
    MODEL_DIR,
    NUM_CLASSES,
    PROCESSED_DIR,
)

ASSETS_MODELS_DIR = Path("../assets/models")
OUTPUT_NAME = "landmark_efficientnet"


# ---------------------------------------------------------------------------
# Temsili veri üretici (INT8 kuantizasyon için)
# ---------------------------------------------------------------------------

def representative_dataset_gen(num_samples: int = 200):
    """
    INT8 kuantizasyon için kalibrasyon verisi sağlar.
    Her sınıftan birkaç görüntü alarak modelin aktivasyon
    aralıklarını gerçekçi biçimde öğrenmesini sağlar.
    """
    processed = Path(PROCESSED_DIR)
    collected = []

    for cls in LANDMARK_CLASSES:
        cls_dir = processed / cls
        images = list(cls_dir.glob("*.jpg"))[:5]  # Sınıf başına 5 görüntü
        collected.extend(images)

    # Yeterli görüntü yoksa sentetik veri kullan
    if len(collected) < 10:
        print("[!] Kalibrasyon verisi bulunamadı, sentetik veri kullanılıyor.")
        for _ in range(num_samples):
            dummy = np.random.randint(0, 256, (1, IMAGE_SIZE, IMAGE_SIZE, 3), dtype=np.uint8)
            yield [dummy.astype(np.float32)]
        return

    np.random.shuffle(collected)
    for img_path in collected[:num_samples]:
        try:
            img = tf.io.read_file(str(img_path))
            img = tf.image.decode_jpeg(img, channels=3)
            img = tf.image.resize(img, [IMAGE_SIZE, IMAGE_SIZE])
            img = tf.expand_dims(img, axis=0)
            yield [img]
        except Exception:
            continue


# ---------------------------------------------------------------------------
# Dönüştürme
# ---------------------------------------------------------------------------

def convert(model_path: str, quant: str) -> bytes:
    """
    Keras modelini TFLite formatına dönüştürür.

    quant:
        "none"    → float32, kuantizasyon yok
        "float16" → ağırlıklar float16'ya düşürülür
        "int8"    → ağırlıklar ve aktivasyonlar INT8 (en küçük model)
    """
    print(f"[→] Model yükleniyor: {model_path}")
    model = keras.models.load_model(model_path)
    print(f"[✓] Model yüklendi — parametre sayısı: {model.count_params():,}")

    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    if quant == "float16":
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
        print("[→] Float16 kuantizasyon uygulanıyor...")

    elif quant == "int8":
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.representative_dataset = representative_dataset_gen
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
        converter.inference_input_type = tf.uint8
        converter.inference_output_type = tf.uint8
        print("[→] INT8 tam kuantizasyon uygulanıyor (kalibrasyon verisi gerekli)...")

    else:  # none — float32
        print("[→] Kuantizasyon uygulanmıyor (float32)...")

    t0 = time.time()
    tflite_model = converter.convert()
    elapsed = time.time() - t0

    size_mb = len(tflite_model) / (1024 * 1024)
    print(f"[✓] Dönüşüm tamamlandı — {elapsed:.1f}s, boyut: {size_mb:.2f} MB")

    return tflite_model


# ---------------------------------------------------------------------------
# Kaydetme
# ---------------------------------------------------------------------------

def save(tflite_model: bytes, quant: str):
    """
    .tflite dosyasını hem ml/models/ hem de Flutter assets klasörüne kaydeder.
    """
    suffix = "" if quant == "float16" else f"_{quant}"
    filename = f"{OUTPUT_NAME}{suffix}.tflite"

    # ml/models/ — yedek kopya
    local_path = Path(MODEL_DIR) / filename
    local_path.parent.mkdir(parents=True, exist_ok=True)
    local_path.write_bytes(tflite_model)
    print(f"[✓] Yedek kaydedildi: {local_path}")

    # assets/models/ — Flutter'ın beklediği konum
    ASSETS_MODELS_DIR.mkdir(parents=True, exist_ok=True)
    # Flutter landmark_efficientnet.tflite adını bekliyor (suffix olmadan)
    flutter_path = ASSETS_MODELS_DIR / f"{OUTPUT_NAME}.tflite"
    shutil.copy2(local_path, flutter_path)
    print(f"[✓] Flutter asset'e kopyalandı: {flutter_path}")

    return flutter_path


# ---------------------------------------------------------------------------
# Doğrulama
# ---------------------------------------------------------------------------

def validate(tflite_path: str, num_tests: int = 5):
    """
    Kaydedilen .tflite modelini TFLite Interpreter ile yükleyip
    rastgele giriş üzerinde çıktı şeklini ve tahmin süresini ölçer.
    """
    print(f"\n[→] Doğrulama başlıyor: {tflite_path}")
    interpreter = tf.lite.Interpreter(model_path=str(tflite_path))
    interpreter.allocate_tensors()

    input_details  = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    input_shape = input_details[0]["shape"]
    input_dtype = input_details[0]["dtype"]
    output_shape = output_details[0]["shape"]

    print(f"  Giriş şekli  : {input_shape}  dtype={input_dtype}")
    print(f"  Çıkış şekli  : {output_shape}")
    print(f"  Sınıf sayısı : {output_shape[-1]}")

    if output_shape[-1] != NUM_CLASSES:
        print(f"[!] UYARI: Beklenen sınıf sayısı {NUM_CLASSES}, model {output_shape[-1]} döndürüyor!")

    # Gecikme ölçümü
    times = []
    for _ in range(num_tests):
        if input_dtype == np.uint8:
            dummy = np.random.randint(0, 256, input_shape, dtype=np.uint8)
        else:
            dummy = np.random.rand(*input_shape).astype(np.float32)

        t0 = time.time()
        interpreter.set_tensor(input_details[0]["index"], dummy)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]["index"])
        times.append(time.time() - t0)

        top_idx = int(np.argmax(output[0]))
        top_conf = float(np.max(output[0]))
        print(f"  Test {_ + 1}: tahmin={LANDMARK_CLASSES[top_idx]}, "
              f"güven={top_conf:.3f}, süre={times[-1]*1000:.1f}ms")

    avg_ms = np.mean(times) * 1000
    print(f"\n[✓] Ortalama çıkarım süresi: {avg_ms:.1f}ms (CPU)")
    print("[i] Gerçek cihaz süresi genellikle 2-5x daha hızlıdır (GPU/NPU)")


# ---------------------------------------------------------------------------
# Model meta verisi
# ---------------------------------------------------------------------------

def write_metadata(flutter_path: Path, quant: str):
    """
    Flutter tarafının model hakkında bilgi edinmesi için
    assets/models/ altına metadata JSON yazar.
    """
    meta = {
        "model_file": flutter_path.name,
        "input_size": IMAGE_SIZE,
        "num_classes": NUM_CLASSES,
        "quantization": quant,
        "class_labels": LANDMARK_CLASSES,
        "normalization": "efficientnet_builtin",  # 0-255 ham piksel, model içinde normalize eder
        "exported_with": "tf.lite.TFLiteConverter",
    }
    meta_path = ASSETS_MODELS_DIR / "model_metadata.json"
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)
    print(f"[✓] Metadata kaydedildi: {meta_path}")


# ---------------------------------------------------------------------------
# Ana giriş noktası
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="TourSup TFLite export")
    parser.add_argument(
        "--model",
        type=str,
        default=f"{MODEL_DIR}/best.keras",
        help="Dönüştürülecek .keras model dosyası",
    )
    parser.add_argument(
        "--quant",
        choices=["none", "float16", "int8"],
        default="float16",
        help="Kuantizasyon türü (varsayılan: float16)",
    )
    parser.add_argument(
        "--skip-validate",
        action="store_true",
        help="Dönüşüm sonrası doğrulama adımını atla",
    )
    args = parser.parse_args()

    print(f"[TourSup] TFLite export başlıyor")
    print(f"  Kaynak model : {args.model}")
    print(f"  Kuantizasyon : {args.quant}")
    print(f"  Hedef        : {ASSETS_MODELS_DIR}/{OUTPUT_NAME}.tflite\n")

    tflite_model = convert(args.model, args.quant)
    flutter_path = save(tflite_model, args.quant)
    write_metadata(flutter_path, args.quant)

    if not args.skip_validate:
        validate(flutter_path)

    print(f"\n[✓] Export tamamlandı.")
    print(f"    Sonraki adım: Flutter uygulamasını derle ve test et.")
