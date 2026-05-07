from app.db.database import get_connection


def get_food_recommendations(duygu_id, limit=10):
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            id,
            isim,
            kart_kisa_aciklama,
            bilimsel_fayda_detay,
            tuketim_onerisi,
            gorsel_url,
            icerik_etiketleri,
            riskli_hastaliklar,
            ozel_durum_uyarisi
        FROM besin_onerileri
        WHERE duygu_id = %s
        ORDER BY id
        LIMIT %s;
    """, (duygu_id, limit))

    rows = cur.fetchall()

    foods = []
    for row in rows:
        foods.append({
            "id": row[0],
            "isim": row[1],
            "kart_kisa_aciklama": row[2],
            "bilimsel_fayda_detay": row[3],
            "tuketim_onerisi": row[4],
            "gorsel_url": row[5] or "",
            "icerik_etiketleri": row[6] or [],
            "riskli_hastaliklar": row[7] or [],
            "ozel_durum_uyarisi": row[8] or [],
            "type": "food"
        })

    cur.close()
    conn.close()
    return foods


def get_activity_recommendations(duygu_id, limit=10):
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            id,
            isim,
            kart_kisa_aciklama,
            bilimsel_fayda_detay,
            uygulama_onerisi,
            gorsel_url,
            riskli_hastaliklar,
            ozel_durum_uyarisi
        FROM aktivite_onerileri
        WHERE duygu_id = %s
        ORDER BY id
        LIMIT %s;
    """, (duygu_id, limit))

    rows = cur.fetchall()

    activities = []
    for row in rows:
        activities.append({
            "id": row[0],
            "isim": row[1],
            "kart_kisa_aciklama": row[2],
            "bilimsel_fayda_detay": row[3],
            "uygulama_onerisi": row[4],
            "gorsel_url": row[5] or "",
            "riskli_hastaliklar": row[6] or [],
            "ozel_durum_uyarisi": row[7] or [],
            "type": "activity"
        })

    cur.close()
    conn.close()
    return activities