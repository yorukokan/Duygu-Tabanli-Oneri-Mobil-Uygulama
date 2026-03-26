CREATE TABLE duygular (
    label_id INTEGER PRIMARY KEY,
    duygu_adi VARCHAR(50) NOT NULL,
    beslenme_genel_ozet TEXT,
    aktivite_genel_ozet TEXT
);

CREATE TABLE besin_onerileri (
    id SERIAL PRIMARY KEY,
    duygu_id INTEGER REFERENCES duygular(label_id),
    isim VARCHAR(100) NOT NULL,
    kart_kisa_aciklama TEXT,
    bilimsel_fayda_detay TEXT,
    tuketim_onerisi TEXT,
    gorsel_url TEXT,
    icerik_etiketleri TEXT[],
    riskli_hastaliklar TEXT[],
    ozel_durum_uyarisi TEXT[]
);

CREATE TABLE aktivite_onerileri (
    id SERIAL PRIMARY KEY,
    duygu_id INTEGER REFERENCES duygular(label_id),
    isim VARCHAR(100) NOT NULL,
    kart_kisa_aciklama TEXT,
    bilimsel_fayda_detay TEXT,
    uygulama_onerisi TEXT,
    gorsel_url TEXT,
    aktivite_turu VARCHAR(50),
    riskli_hastaliklar TEXT[],
    ozel_durum_uyarisi TEXT[]
);