# app/logic/decision_engine.py

EMOJI_TO_PROJECT_EMOTION = {
    "🙂": "nötr_genel_denge",
    "😃": "heyecan_yüksek_enerji",
    "😕": "kaygı_anksiyete",
    "🥺": "kaygı_anksiyete",
    "😞": "depresif_hüzünlü",
    "😠": "öfke_gerginlik",
    "🤯": "odak_eksikliği",
    "😬": "yüksek_stres",
    "🫩": "düşük_enerji_yorgunluk",
    "🥱": "uyku_huzursuzluk",
    "☺️": "mutluluk",
    "🫠": "motivasyon_eksikliği",
}

HYBRID_DECISION_MATRIX = {
    "angry": {
        "🙂": "yüksek_stres",
        "😃": "yüksek_stres",
        "😕": "yüksek_stres",
        "🥺": "kaygı_anksiyete",
        "😞": "yüksek_stres",
        "😠": "öfke_gerginlik",
        "🤯": "kaygı_anksiyete",
        "😬": "yüksek_stres",
        "🫩": "yüksek_stres",
        "🥱": "uyku_huzursuzluk",
        "☺️": "yüksek_stres",
        "🫠": "yüksek_stres",
    },
    "disgust": {
        "🙂": "kaygı_anksiyete",
        "😃": "heyecan_yüksek_enerji",
        "😕": "kaygı_anksiyete",
        "🥺": "kaygı_anksiyete",
        "😞": "depresif_hüzünlü",
        "😠": "öfke_gerginlik",
        "🤯": "odak_eksikliği",
        "😬": "kaygı_anksiyete",
        "🫩": "düşük_enerji_yorgunluk",
        "🥱": "uyku_huzursuzluk",
        "☺️": "nötr_genel_denge",
        "🫠": "kaygı_anksiyete",
    },
    "fear": {
        "🙂": "kaygı_anksiyete",
        "😃": "kaygı_anksiyete",
        "😕": "kaygı_anksiyete",
        "🥺": "kaygı_anksiyete",
        "😞": "depresif_hüzünlü",
        "😠": "öfke_gerginlik",
        "🤯": "kaygı_anksiyete",
        "😬": "kaygı_anksiyete",
        "🫩": "düşük_enerji_yorgunluk",
        "🥱": "uyku_huzursuzluk",
        "☺️": "kaygı_anksiyete",
        "🫠": "kaygı_anksiyete",
    },
    "happy": {
        "🙂": "mutluluk",
        "😃": "heyecan_yüksek_enerji",
        "😕": "mutluluk",
        "🥺": "mutluluk",
        "😞": "mutluluk",
        "😠": "öfke_gerginlik",
        "🤯": "heyecan_yüksek_enerji",
        "😬": "kaygı_anksiyete",
        "🫩": "düşük_enerji_yorgunluk",
        "🥱": "düşük_enerji_yorgunluk",
        "☺️": "mutluluk",
        "🫠": "motivasyon_eksikliği",
    },
    "sad": {
        "🙂": "depresif_hüzünlü",
        "😃": "kaygı_anksiyete",
        "😕": "depresif_hüzünlü",
        "🥺": "depresif_hüzünlü",
        "😞": "depresif_hüzünlü",
        "😠": "yüksek_stres",
        "🤯": "odak_eksikliği",
        "😬": "kaygı_anksiyete",
        "🫩": "düşük_enerji_yorgunluk",
        "🥱": "uyku_huzursuzluk",
        "☺️": "depresif_hüzünlü",
        "🫠": "motivasyon_eksikliği",
    },
    "surprise": {
        "🙂": "heyecan_yüksek_enerji",
        "😃": "heyecan_yüksek_enerji",
        "😕": "odak_eksikliği",
        "🥺": "kaygı_anksiyete",
        "😞": "kaygı_anksiyete",
        "😠": "öfke_gerginlik",
        "🤯": "odak_eksikliği",
        "😬": "kaygı_anksiyete",
        "🫩": "düşük_enerji_yorgunluk",
        "🥱": "uyku_huzursuzluk",
        "☺️": "heyecan_yüksek_enerji",
        "🫠": "motivasyon_eksikliği",
    },
    "neutral": {
        "🙂": "nötr_genel_denge",
        "😃": "heyecan_yüksek_enerji",
        "😕": "kaygı_anksiyete",
        "🥺": "kaygı_anksiyete",
        "😞": "depresif_hüzünlü",
        "😠": "öfke_gerginlik",
        "🤯": "odak_eksikliği",
        "😬": "kaygı_anksiyete",
        "🫩": "düşük_enerji_yorgunluk",
        "🥱": "uyku_huzursuzluk",
        "☺️": "mutluluk",
        "🫠": "motivasyon_eksikliği",
    },
}


def decide_final_emotion(model_emotion: str | None, emoji: str) -> str:
    """
    Fotoğraf yoksa -> sadece emoji tablosu (Tablo 4)
    Fotoğraf varsa -> hibrit karar matrisi (Tablo 5)
    """

    # 1) Emoji tek başına karar
    emoji_based_emotion = EMOJI_TO_PROJECT_EMOTION.get(emoji, "nötr_genel_denge")

    # 2) Model sonucu yoksa direkt emoji sonucunu döndür
    if model_emotion is None:
        return emoji_based_emotion

    model_key = model_emotion.strip().lower()

    # 3) Hibrit tabloda model duygusu varsa onu kullan
    if model_key in HYBRID_DECISION_MATRIX:
        return HYBRID_DECISION_MATRIX[model_key].get(emoji, emoji_based_emotion)

    # 4) Tanınmayan model sonucu gelirse emojiye düş
    return emoji_based_emotion