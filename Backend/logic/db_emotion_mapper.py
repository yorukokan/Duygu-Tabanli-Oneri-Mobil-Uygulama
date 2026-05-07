PROJECT_TO_DB_EMOTION = {
    "yuksek_stres": 0,
    "ofke_gerginlik": 1,
    "kaygi_anksiyete": 2,
    "dusuk_enerji_yorgunluk": 3,
    "motivasyon_eksikligi": 4,
    "depresif_huzunlu": 5,
    "uyku_huzursuzluk": 6,
    "odak_eksikligi": 7,
    "heyecan_yuksek_enerji": 8,
    "yuksek_enerji": 8,
    "mutluluk": 9,
    "notr_genel_denge": 10,
}


def normalize_emotion_key(text: str) -> str:
    if text is None:
        return ""

    return (
        text.strip().lower()
        .replace(" ", "_")
        .replace("/", "_")
        .replace("__", "_")
        .replace("ı", "i")
        .replace("ğ", "g")
        .replace("ü", "u")
        .replace("ş", "s")
        .replace("ö", "o")
        .replace("ç", "c")
    )


def map_project_emotion_to_db_id(project_emotion):
    normalized = normalize_emotion_key(project_emotion)
    return PROJECT_TO_DB_EMOTION.get(normalized)