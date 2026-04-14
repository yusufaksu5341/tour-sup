# Eğitim ve veri hazırlama için merkezi konfigürasyon

IMAGE_SIZE = 224          # EfficientNetB0 giriş boyutu
BATCH_SIZE = 32
EPOCHS = 30
LEARNING_RATE = 1e-4
VALIDATION_SPLIT = 0.2
MIN_IMAGES_PER_CLASS = 50  # Bir sınıfın eğitime girmesi için gereken minimum görüntü

DATA_DIR = "data/raw"          # İndirilen ham görüntüler
PROCESSED_DIR = "data/processed"  # Yeniden boyutlandırılmış, normalize edilmiş
MODEL_DIR = "models"
LABELS_PATH = "../assets/labels/landmark_labels.txt"
CLASS_MAP_PATH = "../assets/labels/landmark_class_map.json"

# landmark_labels.txt ile aynı sırada — index = sınıf etiketi
LANDMARK_CLASSES = [
    "hagia_sophia",         # 0  Ayasofya
    "topkapi",              # 1  Topkapı Sarayı
    "blue_mosque",          # 2  Sultanahmet Camii
    "dolmabahce",           # 3  Dolmabahçe Sarayı
    "galata_tower",         # 4  Galata Kulesi
    "ephesus",              # 5  Efes Antik Kenti
    "cappadocia",           # 6  Kapadokya Peri Bacaları
    "pamukkale",            # 7  Pamukkale Travertenleri
    "nemrut",               # 8  Nemrut Dağı
    "troy",                 # 9  Troya Antik Kenti
    "aspendos",             # 10 Aspendos Tiyatrosu
    "perge",                # 11 Perge Antik Kenti
    "aphrodisias",          # 12 Afrodisias Antik Kenti
    "didyma",               # 13 Didim Apollon Tapınağı
    "bodrum_castle",        # 14 Bodrum Kalesi
    "rumeli_hisari",        # 15 Rumeli Hisarı
    "selimiye",             # 16 Edirne Selimiye Camii
    "bursa_ulucami",        # 17 Bursa Ulucami
    "ani_ruins",            # 18 Ani Harabeleri
    "ishak_pasha",          # 19 İshak Paşa Sarayı
    "sumela",               # 20 Sümela Manastırı
    "gobekli_tepe",         # 21 Göbekli Tepe
    "harran",               # 22 Harran Antik Kenti
    "mount_ararat",         # 23 Ağrı Dağı
    "konya_mevlana",        # 24 Mevlana Müzesi
    "alanya_castle",        # 25 Alanya Kalesi
    "aizanoi",              # 26 Aizanoi Antik Kenti
    "hattusha",             # 27 Hattuşa
    "sardis",               # 28 Sardes Antik Kenti
    "pergamon",             # 29 Bergama Akropolü
    "letoon",               # 30 Letoon Kutsal Alanı
    "xanthos",              # 31 Ksanthos Antik Kenti
    "hierapolis",           # 32 Hierapolis Antik Kenti
    "catalhoyuk",           # 33 Çatalhöyük
    "amasya_tombs",         # 34 Amasya Kral Kaya Mezarları
    "divriği",              # 35 Divriği Ulu Camii ve Darüşşifası
    "dara",                 # 36 Dara Antik Kenti
    "mardin_old_city",      # 37 Mardin Eski Şehri
    "safranbolu",           # 38 Safranbolu Tarihi Kent Merkezi
    "alacahoyuk",           # 39 Alacahöyük
    "kizkalesi",            # 40 Kız Kalesi
    "termessos",            # 41 Termessos Antik Kenti
    "hasankeyf",            # 42 Hasankeyf Antik Kenti
    "tarsus",               # 43 Tarsus Tarihi Merkezi
    "bayrakli_mound",       # 44 Kadifekale
    "prusias_ad_hypium",    # 45 Prusias ad Hypium
    "nicaea",               # 46 İznik Tarihi Surları
    "ottoman_hans",         # 47 Bursa Kapalıçarşısı ve Hanlar Bölgesi
    "beyşehir_lake",        # 48 Eşrefoğlu Camii
]

NUM_CLASSES = len(LANDMARK_CLASSES)  # 49

# Google Landmarks v2 CSV'sindeki bu landmark_id'ler Türkiye yapılarına karşılık gelir.
# Tam liste train_label_to_category.csv ile doğrulanmalıdır.
GOOGLE_LANDMARKS_IDS = {
    "hagia_sophia":      ["116082", "31623"],
    "topkapi":           ["198311"],
    "blue_mosque":       ["136757", "45588"],
    "dolmabahce":        ["184033"],
    "galata_tower":      ["157444"],
    "ephesus":           ["49680",  "125317"],
    "cappadocia":        ["67631",  "106783"],
    "pamukkale":         ["56027"],
    "nemrut":            ["163805"],
    "troy":              ["95604"],
    "aspendos":          ["41537"],
    "gobekli_tepe":      ["176012"],
    "konya_mevlana":     ["103298"],
    "selimiye":          ["74651"],
    "pergamon":          ["120044"],
    "hattusha":          ["188521"],
}
