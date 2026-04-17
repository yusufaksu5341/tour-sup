"""
TourSup — Hızlı Eğitim Pipeline (CPU uyumlu)
Resize → MobileNetV2 transfer learning → TFLite export
"""
import json, os, shutil, sys, time
from pathlib import Path
sys.stdout.reconfigure(encoding="utf-8")
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.applications import MobileNetV2
from PIL import Image
from tqdm import tqdm

# --- Sabitler ---
RAW_DIR       = "data/raw"
PROC_DIR      = "data/processed"
MODEL_DIR     = "models"
ASSETS_DIR    = "../assets/models"
IMAGE_SIZE    = 224
BATCH_SIZE    = 32
EPOCHS_HEAD   = 8
EPOCHS_FINETUNE = 12
LR            = 1e-3
SEED          = 42

CLASSES = [
    "hagia_sophia","topkapi","blue_mosque","dolmabahce","galata_tower",
    "ephesus","cappadocia","pamukkale","nemrut","troy","aspendos","perge",
    "aphrodisias","didyma","bodrum_castle","rumeli_hisari","selimiye",
    "bursa_ulucami","ani_ruins","ishak_pasha","sumela","gobekli_tepe",
    "harran","mount_ararat","konya_mevlana","alanya_castle","aizanoi",
    "hattusha","sardis","pergamon","letoon","xanthos","hierapolis",
    "catalhoyuk","amasya_tombs","divrigi","dara","mardin_old_city",
    "safranbolu","alacahoyuk","kizkalesi","termessos","hasankeyf",
    "tarsus","bayrakli_mound","prusias_ad_hypium","nicaea",
    "ottoman_hans","beysehir_lake",
]
NUM_CLASSES = len(CLASSES)

tf.random.set_seed(SEED)
np.random.seed(SEED)

# ── 1. Resize ────────────────────────────────────────────────────────────────

def resize_all():
    print("── Adım 1: Görüntüler yeniden boyutlandırılıyor ──")
    ok = fail = 0
    for cls in CLASSES:
        src = Path(RAW_DIR, cls)
        dst = Path(PROC_DIR, cls)
        dst.mkdir(parents=True, exist_ok=True)
        imgs = [p for p in src.glob("*") if p.suffix.lower() in {".jpg",".jpeg",".png",".webp"}]
        for p in imgs:
            out = dst / (p.stem + ".jpg")
            if out.exists():
                ok += 1
                continue
            try:
                with Image.open(p) as im:
                    im.convert("RGB").resize((IMAGE_SIZE, IMAGE_SIZE), Image.LANCZOS).save(out, "JPEG", quality=90)
                ok += 1
            except Exception:
                fail += 1
    print(f"  Başarılı: {ok}  Başarısız: {fail}\n")

# ── 2. Dataset ───────────────────────────────────────────────────────────────

def load_datasets():
    common = dict(
        directory=PROC_DIR,
        image_size=(IMAGE_SIZE, IMAGE_SIZE),
        batch_size=BATCH_SIZE,
        seed=SEED,
        validation_split=0.2,
        label_mode="categorical",
    )
    train_ds = keras.utils.image_dataset_from_directory(**common, subset="training")
    val_ds   = keras.utils.image_dataset_from_directory(**common, subset="validation")
    AUTOTUNE = tf.data.AUTOTUNE
    train_ds = train_ds.cache().shuffle(500).prefetch(AUTOTUNE)
    val_ds   = val_ds.cache().prefetch(AUTOTUNE)
    return train_ds, val_ds

# ── 3. Model ─────────────────────────────────────────────────────────────────

def build_model(freeze_base=True):
    inputs = keras.Input(shape=(IMAGE_SIZE, IMAGE_SIZE, 3))
    x = layers.Rescaling(1./127.5, offset=-1)(inputs)   # MobileNetV2: [-1, 1]
    x = layers.RandomFlip("horizontal")(x)
    x = layers.RandomRotation(0.1)(x)
    x = layers.RandomZoom(0.1)(x)

    base = MobileNetV2(include_top=False, weights="imagenet", input_tensor=x, pooling="avg")
    base.trainable = not freeze_base

    x = base.output
    x = layers.Dropout(0.3)(x)
    x = layers.Dense(256, activation="relu")(x)
    x = layers.Dropout(0.2)(x)
    outputs = layers.Dense(NUM_CLASSES, activation="softmax")(x)
    return keras.Model(inputs, outputs), base

def compile_model(model, lr):
    model.compile(
        optimizer=keras.optimizers.Adam(lr),
        loss="categorical_crossentropy",
        metrics=["accuracy", keras.metrics.TopKCategoricalAccuracy(k=3, name="top3")],
    )

# ── 4. Eğitim ────────────────────────────────────────────────────────────────

def train():
    print("── Adım 2: Model eğitiliyor ──")
    Path(MODEL_DIR).mkdir(exist_ok=True)
    train_ds, val_ds = load_datasets()

    ckpt = keras.callbacks.ModelCheckpoint(
        f"{MODEL_DIR}/best.keras", monitor="val_accuracy",
        save_best_only=True, verbose=0,
    )
    early = keras.callbacks.EarlyStopping(
        monitor="val_accuracy", patience=6, restore_best_weights=True, verbose=1,
    )
    reduce_lr = keras.callbacks.ReduceLROnPlateau(
        monitor="val_loss", factor=0.5, patience=3, min_lr=1e-7, verbose=0,
    )

    # Phase 1 — sadece kafa
    model, base = build_model(freeze_base=True)
    compile_model(model, LR)
    print(f"  Phase 1: {EPOCHS_HEAD} epoch (base dondurulmuş)")
    h1 = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS_HEAD,
                   callbacks=[ckpt, early, reduce_lr], verbose=1)

    # Phase 2 — son 30 katman çözülür
    print(f"\n  Phase 2: {EPOCHS_FINETUNE} epoch (fine-tune)")
    base.trainable = True
    for layer in base.layers[:-30]:
        layer.trainable = False
    compile_model(model, LR / 10)
    h2 = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS_FINETUNE,
                   initial_epoch=len(h1.history["loss"]),
                   callbacks=[ckpt, early, reduce_lr], verbose=1)

    model.save(f"{MODEL_DIR}/last.keras")

    # Geçmişi kaydet
    hist = {}
    for k in h1.history:
        hist[k] = h1.history[k] + h2.history.get(k, [])
    with open(f"{MODEL_DIR}/history.json", "w") as f:
        json.dump(hist, f, indent=2)

    best_acc = max(hist.get("val_accuracy", [0]))
    best_top3 = max(hist.get("val_top3", [0]))
    print(f"\n  En iyi val_accuracy : %{best_acc*100:.2f}")
    print(f"  En iyi val_top3     : %{best_top3*100:.2f}\n")
    return model

# ── 5. TFLite Export ─────────────────────────────────────────────────────────

def export_tflite(model):
    print("── Adım 3: TFLite export ──")
    Path(ASSETS_DIR).mkdir(parents=True, exist_ok=True)

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]
    tflite_model = converter.convert()

    out_path = Path(ASSETS_DIR) / "landmark_efficientnet.tflite"
    out_path.write_bytes(tflite_model)
    size_mb = len(tflite_model) / (1024*1024)
    print(f"  Kaydedildi: {out_path}  ({size_mb:.2f} MB)")

    # Metadata
    meta = {
        "model_file": "landmark_efficientnet.tflite",
        "architecture": "MobileNetV2",
        "input_size": IMAGE_SIZE,
        "num_classes": NUM_CLASSES,
        "quantization": "float16",
        "normalization": "rescaling_127.5_minus1",
        "class_labels": CLASSES,
    }
    with open(Path(ASSETS_DIR) / "model_metadata.json", "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)
    print("  metadata.json güncellendi")

    # Interpreter doğrulama
    interp = tf.lite.Interpreter(model_path=str(out_path))
    interp.allocate_tensors()
    in_d  = interp.get_input_details()[0]
    out_d = interp.get_output_details()[0]
    dummy = np.random.rand(1, IMAGE_SIZE, IMAGE_SIZE, 3).astype(np.float32)
    interp.set_tensor(in_d["index"], dummy)
    interp.invoke()
    result = interp.get_tensor(out_d["index"])
    top = int(np.argmax(result[0]))
    print(f"  Doğrulama OK — çıktı şekli: {result.shape}, test tahmini: {CLASSES[top]}")

# ── Ana akış ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    t0 = time.time()
    resize_all()
    model = train()
    export_tflite(model)
    print(f"\n[✓] Pipeline tamamlandı — toplam süre: {(time.time()-t0)/60:.1f} dakika")
    print("    Model: assets/models/landmark_efficientnet.tflite")
