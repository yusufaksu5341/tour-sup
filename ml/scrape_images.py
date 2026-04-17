"""
Bing Image Search ile her landmark için görüntü indirir.
API anahtarı gerektirmez.
"""
import os
from pathlib import Path
from icrawler.builtin import BingImageCrawler

DATA_DIR = "data/raw"
MAX_PER_CLASS = 60

LANDMARKS = {
    "hagia_sophia":      "Hagia Sophia Istanbul Turkey",
    "topkapi":           "Topkapi Palace Istanbul Turkey",
    "blue_mosque":       "Blue Mosque Sultan Ahmed Istanbul Turkey",
    "dolmabahce":        "Dolmabahce Palace Istanbul Turkey",
    "galata_tower":      "Galata Tower Istanbul Turkey",
    "ephesus":           "Ephesus ancient ruins Turkey",
    "cappadocia":        "Cappadocia fairy chimneys Turkey",
    "pamukkale":         "Pamukkale travertines Turkey",
    "nemrut":            "Nemrut Dagi statues Turkey",
    "troy":              "Troy ancient city Canakkale Turkey",
    "aspendos":          "Aspendos theatre Antalya Turkey",
    "perge":             "Perge ancient city Antalya Turkey",
    "aphrodisias":       "Aphrodisias ancient city Turkey",
    "didyma":            "Didyma Apollo Temple Turkey",
    "bodrum_castle":     "Bodrum Castle Turkey",
    "rumeli_hisari":     "Rumeli Fortress Istanbul Turkey",
    "selimiye":          "Selimiye Mosque Edirne Turkey",
    "bursa_ulucami":     "Bursa Ulu Camii Grand Mosque Turkey",
    "ani_ruins":         "Ani ruins Kars Turkey",
    "ishak_pasha":       "Ishak Pasha Palace Agri Turkey",
    "sumela":            "Sumela Monastery Trabzon Turkey",
    "gobekli_tepe":      "Gobekli Tepe archaeological site Turkey",
    "harran":            "Harran ancient city beehive houses Turkey",
    "mount_ararat":      "Mount Ararat Agri Turkey",
    "konya_mevlana":     "Mevlana Museum Konya Turkey",
    "alanya_castle":     "Alanya Castle Turkey",
    "aizanoi":           "Aizanoi Zeus Temple Kutahya Turkey",
    "hattusha":          "Hattusa Hittite ruins Corum Turkey",
    "sardis":            "Sardis ancient city Manisa Turkey",
    "pergamon":          "Pergamon Acropolis Bergama Turkey",
    "letoon":            "Letoon sanctuary Mugla Turkey",
    "xanthos":           "Xanthos ancient city Mugla Turkey",
    "hierapolis":        "Hierapolis ancient city Pamukkale Turkey",
    "catalhoyuk":        "Catalhoyuk neolithic site Konya Turkey",
    "amasya_tombs":      "Amasya rock tombs Pontic kings Turkey",
    "divriği":           "Divrigi Ulu Camii Sivas Turkey",
    "dara":              "Dara ancient city Mardin Turkey",
    "mardin_old_city":   "Mardin old city historic Turkey",
    "safranbolu":        "Safranbolu historic town Turkey",
    "alacahoyuk":        "Alacahoyuk Hittite ruins Corum Turkey",
    "kizkalesi":         "Kizkalesi sea castle Mersin Turkey",
    "termessos":         "Termessos ancient city Antalya Turkey",
    "hasankeyf":         "Hasankeyf ancient city Batman Turkey",
    "tarsus":            "Tarsus historic city Mersin Turkey",
    "bayrakli_mound":    "Kadifekale Izmir Turkey",
    "prusias_ad_hypium": "Prusias ad Hypium ancient Duzce Turkey",
    "nicaea":            "Iznik Nicaea historic walls Turkey",
    "ottoman_hans":      "Bursa Kapali Carsi Ottoman hans Turkey",
    "beyşehir_lake":     "Esrefoglu Mosque Beysehir Konya Turkey",
}


def scrape():
    Path(DATA_DIR).mkdir(parents=True, exist_ok=True)
    total = len(LANDMARKS)

    for i, (cls, query) in enumerate(LANDMARKS.items(), 1):
        dst = Path(DATA_DIR, cls)
        dst.mkdir(parents=True, exist_ok=True)

        existing = len(list(dst.glob("*.jpg")))
        needed = MAX_PER_CLASS - existing
        if needed <= 0:
            print(f"[{i}/{total}] {cls}: zaten {existing} görüntü var, atlandı")
            continue

        print(f"[{i}/{total}] {cls}: {needed} görüntü indiriliyor...")
        try:
            crawler = BingImageCrawler(
                storage={"root_dir": str(dst)},
                downloader_threads=4,
            )
            crawler.crawl(
                keyword=query,
                max_num=needed,
                filters={"size": "medium"},
            )
        except Exception as e:
            print(f"  [!] Hata: {e}")

    print("\n[✓] İndirme tamamlandı.")


if __name__ == "__main__":
    scrape()
