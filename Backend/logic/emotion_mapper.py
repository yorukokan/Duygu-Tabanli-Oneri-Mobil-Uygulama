FER_TO_PROJECT = {
    "angry": "ofke_gerginlik",
    "disgust": "kaygi_anksiyete",
    "fear": "kaygi_anksiyete",
    "happy": "mutluluk",
    "sad": "depresif_huzunlu",
    "surprise": "yuksek_enerji",
    "neutral": "notr_genel_denge",
}

def map_model_emotion(model_emotion):
    return FER_TO_PROJECT.get(model_emotion, "notr_genel_denge")