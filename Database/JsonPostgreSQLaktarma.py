import json # Json dosyaları okumak için kullandık
import psycopg2 # PostgreSQL ile bağlantı için hazır olan bu kütüphaneyi kullandık.

# Veritabanına Bağlanma
# Güvenlik için bilgileri sildim.
conn = psycopg2.connect(
    host="localhost",
    database="",
    user="",
    password="",
    port=""
)
# Cursor Sql kodlarını çalıştırmamızı sağlıyor.
cursor = conn.cursor()

# JSON dosyasını okuma
with open('JSON.txt', 'r', encoding='utf-8') as file:
    data = json.load(file)

# Verileri PostgreSQL'e aktardık.
for duygu in data['duygu_kutuphanesi']:

    # Duygular Tablosu
    cursor.execute("""
                   INSERT INTO duygular (label_id, duygu_adi, beslenme_genel_ozet, aktivite_genel_ozet)
                   VALUES (%s, %s, %s, %s) ON CONFLICT (label_id) DO NOTHING;
                   """,
                   (duygu['label_id'], duygu['duygu_adi'], duygu['beslenme_genel_ozet'], duygu['aktivite_genel_ozet']))

    # Besinler Tablosu
    for besin in duygu['beslenme_onerileri']:
        cursor.execute("""
                       INSERT INTO besin_onerileri (duygu_id, isim, kart_kisa_aciklama, bilimsel_fayda_detay,
                                                    tuketim_onerisi, gorsel_url, icerik_etiketleri, riskli_hastaliklar,
                                                    ozel_durum_uyarisi)
                       VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                       """, (
                           duygu['label_id'],
                           besin['isim'],
                           besin['kart_kisa_aciklama'],
                           besin['bilimsel_fayda_detay'],
                           besin.get('tuketim_onerisi', ''),
                           besin['gorsel_url'],
                           besin.get('icerik_etiketleri', []),
                           besin.get('riskli_hastaliklar', []),
                           besin.get('ozel_durum_uyarisi', [])
                       ))

    # Aktiviteler Tablosu
    for aktivite in duygu['aktivite_onerileri']:
        cursor.execute("""
                       INSERT INTO aktivite_onerileri (duygu_id, isim, kart_kisa_aciklama, bilimsel_fayda_detay,
                                                       uygulama_onerisi, gorsel_url, aktivite_turu, riskli_hastaliklar,
                                                       ozel_durum_uyarisi)
                       VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                       """, (
                           duygu['label_id'],
                           aktivite['isim'],
                           aktivite['kart_kisa_aciklama'],
                           aktivite['bilimsel_fayda_detay'],
                           aktivite.get('uygulama_onerisi', ''),
                           aktivite['gorsel_url'],
                           aktivite.get('aktivite_turu', None),
                           aktivite.get('riskli_hastaliklar', []),
                           aktivite.get('ozel_durum_uyarisi', [])
                       ))

# Kaydetme
conn.commit()
cursor.close()
conn.close()
print("JSON.txt verileri PostgreSQL tablolarına aktarıldı.")