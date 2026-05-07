from fastapi import FastAPI, UploadFile, File, Form
import os
import json

from app.model.fer_ready_model import predict_emotion
from app.logic.decision_engine import decide_final_emotion
from app.logic.db_emotion_mapper import map_project_emotion_to_db_id
from app.db.queries import get_food_recommendations, get_activity_recommendations

app = FastAPI()


@app.get("/")
def root():
    return {"message": "Backend çalışıyor"}


@app.get("/health")
def health():
    return {"status": "ok"}


# =========================
# HELPERS
# =========================

def normalize_list(lst):
    if not isinstance(lst, list):
        return []
    return [str(x).lower().strip() for x in lst]


def has_match(user_values, item_values):
    user_values = normalize_list(user_values)
    item_values = normalize_list(item_values)

    for u in user_values:
        for i in item_values:
            if u in i or i in u:
                return True
    return False


# =========================
# FILTERS
# =========================

def filter_foods(foods, allergies, diseases, sensitivities, special_conditions):
    filtered = []

    for food in foods:
        tags = normalize_list(food.get("icerik_etiketleri", []))
        risks = normalize_list(food.get("riskli_hastaliklar", []))
        warnings = normalize_list(food.get("ozel_durum_uyarisi", []))

        if has_match(allergies, tags):
            continue

        if has_match(sensitivities, tags):
            continue

        if has_match(diseases, risks):
            continue

        if has_match(special_conditions, warnings):
            continue

        filtered.append(food)

    return filtered


def filter_activities(activities, diseases, special_conditions):
    filtered = []

    for act in activities:
        risks = normalize_list(act.get("riskli_hastaliklar", []))
        warnings = normalize_list(act.get("ozel_durum_uyarisi", []))

        if has_match(diseases, risks):
            continue

        if has_match(special_conditions, warnings):
            continue

        filtered.append(act)

    return filtered


# =========================
# MAIN ENDPOINT
# =========================

@app.post("/analyze-emotion")
async def analyze_emotion(
    file: UploadFile | None = File(None),
    emoji: str = Form(...),
    health_data: str = Form("{}")
):
    temp_file_path = "temp_upload.jpg"

    try:
        model_result = {"emotion": "AI Analizi Yok"}
        model_emotion = None

        # IMAGE ANALYSIS
        if file is not None:
            with open(temp_file_path, "wb") as buffer:
                buffer.write(await file.read())

            model_result = predict_emotion(temp_file_path)
            model_emotion = model_result.get("emotion")

        # FINAL EMOTION
        final_emotion = decide_final_emotion(model_emotion, emoji)
        duygu_id = map_project_emotion_to_db_id(final_emotion)

        # DB FETCH
        foods = get_food_recommendations(duygu_id)
        activities = get_activity_recommendations(duygu_id)

        # HEALTH PARSE
        try:
            health = json.loads(health_data)
        except:
            health = {}

        allergies = health.get("allergies", [])
        sensitivities = health.get("sensitivities", [])
        diseases = health.get("diseases", [])
        special_conditions = health.get("specialConditions", [])

        # FILTER APPLY
        foods = filter_foods(
            foods,
            allergies,
            diseases,
            sensitivities,
            special_conditions
        )

        activities = filter_activities(
            activities,
            diseases,
            special_conditions
        )

        return {
            "success": True,
            "filename": file.filename if file is not None else None,
            "selected_emoji": emoji,
            "model_result": model_result,
            "final_emotion": final_emotion,
            "duygu_id": duygu_id,
            "food_recommendations": foods,
            "activity_recommendations": activities
        }

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }

    finally:
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)