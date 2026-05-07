from transformers import pipeline
from PIL import Image
import cv2

MODEL_NAME = "abhilash88/face-emotion-detection"
LABEL_MAP = {
    "LABEL_0": "angry",
    "LABEL_1": "disgust",
    "LABEL_2": "fear",
    "LABEL_3": "happy",
    "LABEL_4": "sad",
    "LABEL_5": "surprise",
    "LABEL_6": "neutral",
}

classifier = pipeline("image-classification", model=MODEL_NAME)

def detect_face(image_path: str, output_face_path: str = "cropped_face.jpg") -> str:
    image = cv2.imread(image_path)
    if image is None:
        raise ValueError("Görsel okunamadı")

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    face_cascade = cv2.CascadeClassifier(
        cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
    )

    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)

    if len(faces) == 0:
        raise ValueError("Yüz bulunamadı")

    x, y, w, h = faces[0]
    face = image[y:y+h, x:x+w]

    cv2.imwrite(output_face_path, face)
    return output_face_path


def predict_emotion(image_path: str):
    face_path = detect_face(image_path)

    image = Image.open(face_path).convert("RGB")
    results = classifier(image)

    top_result = results[0]
    raw_label = top_result["label"]
    mapped_label = LABEL_MAP.get(raw_label, raw_label)

    return {
        "emotion": mapped_label,
        "confidence": round(float(top_result["score"]), 4),
        "all_results": [
            {
                "label": LABEL_MAP.get(item["label"], item["label"]),
                "score": round(float(item["score"]), 4)
            }
            for item in results
        ]
    }

def capture_photo_from_camera(save_path="captured_image.jpg"):
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        raise ValueError("Kamera açılamadı")

    print("Kamera açıldı. Fotoğraf çekmek için SPACE, çıkmak için ESC.")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Kameradan görüntü alınamadı.")
            break

        cv2.imshow("Kamera", frame)
        key = cv2.waitKey(1)

        if key == 32:  # SPACE
            cv2.imwrite(save_path, frame)
            print(f"Fotoğraf kaydedildi: {save_path}")
            break
        elif key == 27:  # ESC
            print("Çıkış yapıldı.")
            save_path = None
            break

    cap.release()
    cv2.destroyAllWindows()
    return save_path

if __name__ == "__main__":
    result = predict_emotion("/Users/okan/PycharmProjects/ddyaos/test_image.jpg")
    print(result)