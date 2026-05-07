EMOJI_TO_PROJECT = {
    "🙂": "notr_genel_denge",
    "😃": "yuksek_enerji",
    "😕": "kaygi_anksiyete",
    "🥺": "kaygi_anksiyete",
    "😞": "depresif_huzunlu",
    "😠": "ofke_gerginlik",
    "🤯": "odak_eksikligi",
    "😬": "yuksek_stres",
    "🫩": "dusuk_enerji_yorgunluk",
    "🥱": "uyku_huzursuzluk",
    "☺️": "mutluluk",
    "🫠": "motivasyon_eksikligi",
}

def map_emoji_emotion(emoji):
    return EMOJI_TO_PROJECT.get(emoji, "notr_genel_denge")