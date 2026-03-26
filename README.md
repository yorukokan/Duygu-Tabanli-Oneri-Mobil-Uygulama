# 🧠 Duygu Durumu Analizi ile Kişiselleştirilmiş Beslenme ve Aktivite Önerisi Sunan Yapay Zekâ Destekli Mobil Uygulama

<p align="center">
  <a href="https://github.com/yorukokan/Duygu-Tabanli-Oneri-Mobil-Uygulama">
    <img src="https://img.shields.io/badge/GitHub-Kaynak_Kodlar-181717?style=for-the-badge&logo=github" />
  </a>
  <img src="https://img.shields.io/badge/Necmettin%20Erbakan%20Üniversitesi-Bilgisayar%20Mühendisliği-005195?style=for-the-badge" />
  <img src="https://img.shields.io/badge/PyTorch-%23EE4C2C.svg?style=for-the-badge&logo=PyTorch&logoColor=white" />
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" />
</p>

---
## 📌 Proje Hakkında (Özgün Değer)
Günümüzde bireylerin beslenme ve fiziksel aktivite tercihleri; stres, kaygı ve motivasyon gibi ruhsal faktörlerden doğrudan etkilenmektedir. Bu projenin **özgün değeri**, mevcut sağlık uygulamalarının aksine, kullanıcının anlık ruh halini analiz sürecine dahil eden bütünsel bir dijital destek sistemi sunmasıdır.

* **Bütünsel Yaklaşım:** Fiziksel ve zihinsel durumu birlikte ele alır.
* **Akıllı Algoritma:** Görüntü işleme ile anlık duygu tespiti yapar.
* **Bilimsel Temelli Öneriler:** Literatürdeki besinlerin ve aktivitelerin psikolojik etkilerini temel alan karar destek mekanizması.

---

## 🚀 Teknik Mimari ve Yöntemler

### 1. Yapay Zekâ ve Görüntü İşleme
* **Model:** Yüz ifadelerinden duygu tespiti için **Evrişimli Sinir Ağları (CNN)** mimarisi kullanılmaktadır.
* **Veri Seti:** Model eğitimi için Mutlu, Üzgün, Öfkeli gibi 7 temel duygu sınıfını kapsayan **FER-2013** veri seti tercih edilmiştir.
* **Hibrit Model:** Kamera tabanlı analize alternatif olarak emoji tabanlı manuel duygu seçimi entegre edilmiştir.

### 2. Teknoloji Yığını (Software Stack)
* **Programlama Dili:** Python.
* **Mobil UI:** Flutter (Android & iOS).
* **Backend:** FastAPI / Django (Python tabanlı API servisleri).
* **Veri Tabanı:** Hibrit mimari (PostgreSQL & Firebase NoSQL).
* **Kütüphaneler:** OpenCV, PyTorch, NumPy, Pandas, Matplotlib.

### 3. Donanım Gereksinimleri
* **Uç Cihaz:** Yüksek çözünürlüklü ön kameraya sahip responsive uyumlu akıllı telefonlar.

---

## 📊 Hibrit Duygu Harmanlama Matrisi
Sistem, yapay zekâ tespiti ile kullanıcı girdisi çeliştiğinde "Duygu Harmanlama Matrisi" kullanarak nihai kararı verir.

| FER-2013 Tespiti | Seçilen Emoji | Nihai Karar (Örnek) |
| :--- | :--- | :--- |
| **Angry (Öfke)** | 😬 | Yüksek Stres |
| **Sad (Üzgün)** | 🥺 | Depresif / Hüzünlü |
| **Neutral (Nötr)** | 🙂 | Nötr / Genel Denge |

---

## 📅 15 Haftalık İş-Zaman Çizelgesi

| Hafta | Faaliyet Alanı | Detaylar |
| :--- | :--- | :--- |
| **1** | Teknoloji Araştırması | Teknik altyapı ve kütüphanelerin belirlenmesi. |
| **2** | Literatür Taraması | Duygu durumu ve beslenme ilişkisi üzerine akademik inceleme. |
| **3** | Gereksinim Analizi | Kullanıcı ihtiyaçları ve sistem genel yapısının oluşturulması. |
| **4-5** | UI/UX Tasarım | Figma/Stitch ile kullanıcı deneyimi ve prototipleme. |
| **6** | Veri Seti Hazırlığı | FER-2013 veri seti seçimi ve JSON kütüphane yapılandırması. |
| **7** | Model Tasarımı | Model yapısının belirlenmesi ve komisyon hazırlığı. |
| **8-9** | Model Geliştirme | Yapay zekâ model eğitimi ve sonuçların analizi. |
| **10** | Backend Geliştirme | API yapısı ve veri iletişimi altyapısı. |
| **11** | Frontend Geliştirme | Mobil uygulamanın arayüz kodlaması. |
| **12** | Entegrasyon | AI, Backend ve Mobil bileşenlerin birleştirilmesi. |
| **13** | İyileştirme | Performans optimizasyonu ve hata giderimi. |
| **14** | Test Süreci | Kullanıcı testleri ve geri bildirimlerin toplanması. |
| **15** | Final & Sunum | Proje raporunun tamamlanması ve sunum hazırlığı. |

---

## 👥 Proje Ekibi

**Geliştirici:** [Zeynep Çiğdem ŞAHİN (24100011816)](https://github.com/zcigdemsahin)        
**Geliştirici:** [Okan YÖRÜK (22100011067)](https://github.com/yorukokan)               
**Danışman:** [Dr. Öğr. Üyesi Ayşe Merve ACILAR](https://github.com/amacilar)                  

---
*Bu çalışma Necmettin Erbakan Üniversitesi Bilgisayar Mühendisliği Uygulama Tasarımı dersi kapsamında geliştirilmektedir.*
