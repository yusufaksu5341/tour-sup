"""
TourSup — EfficientNetB0 Transfer Learning Eğitim Scripti
==========================================================
Kullanım:
    python train.py                         # Tam eğitim
    python train.py --epochs 10             # Hızlı deneme
    python train.py --resume models/best.keras  # Kaldığı yerden devam

Çıktı:
    models/best.keras        — doğrulama kaybı en düşük model
    models/last.keras        — son epoch modeli
    models/history.json      — loss/accuracy geçmişi
"""

import argparse
import json
import os
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.applications import EfficientNetB0

from config import (
    BATCH_SIZE,
    EPOCHS,
    IMAGE_SIZE,
    LEARNING_RATE,
    MODEL_DIR,
    NUM_CLASSES,
    PROCESSED_DIR,
    VALIDATION_SPLIT,
)

# ---------------------------------------------------------------------------
# Tekrarlanabilirlik
# ---------------------------------------------------------------------------
SEED = 42
tf.random.set_seed(SEED)
np.random.seed(SEED)


# ---------------------------------------------------------------------------
# Veri yükleme
# ---------------------------------------------------------------------------

def load_datasets():
    """
    PROCESSED_DIR altındaki alt klasör yapısını (ImageFolder formatı) kullanarak
    eğitim ve doğrulama veri setlerini oluşturur.

    Klasör yapısı beklentisi:
        data/processed/
            hagia_sophia/  *.jpg
            topkapi/       *.jpg
            ...
    """
    common_args = dict(
        directory=PROCESSED_DIR,
        image_size=(IMAGE_SIZE, IMAGE_SIZE),
        batch_size=BATCH_SIZE,
        seed=SEED,
        validation_split=VALIDATION_SPLIT,
    )

    train_ds = keras.utils.image_dataset_from_directory(
        **common_args,
        subset="training",
        label_mode="categorical",
    )

    val_ds = keras.utils.image_dataset_from_directory(
        **common_args,
        subset="validation",
        label_mode="categorical",
    )

    class_names = train_ds.class_names
    print(f"[✓] Sınıflar ({len(class_names)}): {class_names[:5]} ...")

    # Sınıf sırası config.py ile eşleşmeli — uyuşmazlık varsa uyar
    from config import LANDMARK_CLASSES
    if class_names != LANDMARK_CLASSES:
        print(
            "[!] UYARI: Klasör sırası config.LANDMARK_CLASSES ile uyuşmuyor.\n"
            "    Model tahminleri yanlış etiketlenebilir.\n"
            "    data/processed/ klasörlerini config sırasına göre düzenleyin."
        )

    return train_ds, val_ds, class_names


# ---------------------------------------------------------------------------
# Veri artırma (augmentation)
# ---------------------------------------------------------------------------

def build_augmentation():
    """
    Eğitim sırasında görüntülere rastgele dönüşüm uygular.
    Farklı ışık koşulları ve açıları simüle ederek modelin
    gerçek dünya fotoğraflarına genellemesini güçlendirir.
    """
    return keras.Sequential(
        [
            layers.RandomFlip("horizontal"),
            layers.RandomRotation(0.15),
            layers.RandomZoom(0.15),
            layers.RandomBrightness(0.2),
            layers.RandomContrast(0.2),
        ],
        name="augmentation",
    )


# ---------------------------------------------------------------------------
# Model inşası
# ---------------------------------------------------------------------------

def build_model(num_classes: int = NUM_CLASSES, freeze_base: bool = True):
    """
    EfficientNetB0 üzerine sınıflandırma kafası ekler.

    freeze_base=True  → Yalnızca kafa eğitilir  (Phase 1: feature extraction)
    freeze_base=False → Tüm ağ eğitilir         (Phase 2: fine-tuning)
    """
    inputs = keras.Input(shape=(IMAGE_SIZE, IMAGE_SIZE, 3))

    # EfficientNetB0 kendi içinde normalizasyon yapıyor (0-255 beklentisi)
    x = build_augmentation()(inputs)

    base = EfficientNetB0(
        include_top=False,
        weights="imagenet",
        input_tensor=x,
        pooling="avg",
    )
    base.trainable = not freeze_base

    x = base.output
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.4)(x)
    x = layers.Dense(256, activation="relu")(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(num_classes, activation="softmax")(x)

    model = keras.Model(inputs, outputs)
    return model, base


# ---------------------------------------------------------------------------
# Eğitim
# ---------------------------------------------------------------------------

def compile_model(model, lr: float):
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=lr),
        loss="categorical_crossentropy",
        metrics=["accuracy", keras.metrics.TopKCategoricalAccuracy(k=3, name="top3_acc")],
    )


def get_callbacks(model_dir: str):
    Path(model_dir).mkdir(parents=True, exist_ok=True)
    return [
        # En iyi val_accuracy'yi kaydet
        keras.callbacks.ModelCheckpoint(
            filepath=os.path.join(model_dir, "best.keras"),
            monitor="val_accuracy",
            save_best_only=True,
            verbose=1,
        ),
        # 5 epoch boyunca iyileşme yoksa öğrenme hızını yarıya indir
        keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.5,
            patience=5,
            min_lr=1e-7,
            verbose=1,
        ),
        # 10 epoch boyunca iyileşme yoksa eğitimi durdur
        keras.callbacks.EarlyStopping(
            monitor="val_accuracy",
            patience=10,
            restore_best_weights=True,
            verbose=1,
        ),
        keras.callbacks.TensorBoard(log_dir=os.path.join(model_dir, "logs")),
    ]


def train(args):
    # --- Veri ---
    train_ds, val_ds, class_names = load_datasets()

    # Performans için önbelleğe al ve prefetch yap
    AUTOTUNE = tf.data.AUTOTUNE
    train_ds = train_ds.cache().shuffle(1000).prefetch(AUTOTUNE)
    val_ds = val_ds.cache().prefetch(AUTOTUNE)

    # --- Phase 1: Yalnızca kafa eğitimi ---
    print("\n[Phase 1] Feature extraction — base model dondurulmuş")
    model, base = build_model(freeze_base=True)

    if args.resume:
        print(f"[→] Checkpoint yükleniyor: {args.resume}")
        model = keras.models.load_model(args.resume)
    else:
        compile_model(model, lr=LEARNING_RATE)

    model.summary(show_trainable=True)

    history1 = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=min(args.epochs, 10),  # Phase 1 en fazla 10 epoch
        callbacks=get_callbacks(MODEL_DIR),
    )

    # --- Phase 2: Fine-tuning (son 40 katman çözülür) ---
    print("\n[Phase 2] Fine-tuning — base model son 40 katmanı çözülüyor")
    base.trainable = True
    for layer in base.layers[:-40]:
        layer.trainable = False

    compile_model(model, lr=LEARNING_RATE / 10)  # Daha düşük LR

    remaining_epochs = max(1, args.epochs - 10)
    history2 = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=remaining_epochs,
        initial_epoch=len(history1.history["loss"]),
        callbacks=get_callbacks(MODEL_DIR),
    )

    # --- Kaydet ---
    model.save(os.path.join(MODEL_DIR, "last.keras"))
    print(f"[✓] Son model kaydedildi: {MODEL_DIR}/last.keras")

    # --- Geçmişi birleştir ve JSON'a yaz ---
    combined = {}
    for key in history1.history:
        combined[key] = history1.history[key] + history2.history.get(key, [])

    history_path = os.path.join(MODEL_DIR, "history.json")
    with open(history_path, "w") as f:
        json.dump(combined, f, indent=2)
    print(f"[✓] Eğitim geçmişi kaydedildi: {history_path}")

    _plot_history(combined, MODEL_DIR)

    # --- Sonuç özeti ---
    best_val_acc = max(combined.get("val_accuracy", [0]))
    best_top3 = max(combined.get("val_top3_acc", [0]))
    print(f"\n{'='*50}")
    print(f"  En iyi val_accuracy : %{best_val_acc*100:.2f}")
    print(f"  En iyi val_top3_acc : %{best_top3*100:.2f}")
    print(f"  Sonraki adım        : python export_tflite.py")
    print(f"{'='*50}\n")

    return model, class_names


# ---------------------------------------------------------------------------
# Grafik
# ---------------------------------------------------------------------------

def _plot_history(history: dict, model_dir: str):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(history["accuracy"], label="Eğitim")
    ax1.plot(history["val_accuracy"], label="Doğrulama")
    ax1.set_title("Accuracy")
    ax1.set_xlabel("Epoch")
    ax1.legend()

    ax2.plot(history["loss"], label="Eğitim")
    ax2.plot(history["val_loss"], label="Doğrulama")
    ax2.set_title("Loss")
    ax2.set_xlabel("Epoch")
    ax2.legend()

    plot_path = os.path.join(model_dir, "training_history.png")
    plt.tight_layout()
    plt.savefig(plot_path, dpi=150)
    plt.close()
    print(f"[✓] Grafik kaydedildi: {plot_path}")


# ---------------------------------------------------------------------------
# Ana giriş noktası
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="TourSup EfficientNetB0 eğitimi")
    parser.add_argument(
        "--epochs",
        type=int,
        default=EPOCHS,
        help=f"Toplam epoch sayısı (varsayılan: {EPOCHS})",
    )
    parser.add_argument(
        "--resume",
        type=str,
        default=None,
        help="Devam edilecek .keras checkpoint dosyası",
    )
    args = parser.parse_args()

    print(f"[TourSup] EfficientNetB0 eğitimi başlıyor")
    print(f"  Sınıf sayısı : {NUM_CLASSES}")
    print(f"  Giriş boyutu : {IMAGE_SIZE}x{IMAGE_SIZE}")
    print(f"  Epoch        : {args.epochs}")
    print(f"  Batch size   : {BATCH_SIZE}")
    print(f"  Veri dizini  : {PROCESSED_DIR}\n")

    train(args)
