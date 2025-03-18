# Product Requirements Document (PRD)

## 1. Proje Özeti
Bu proje, Frankfurter API kullanılarak geliştirilmiş, döviz dönüştürücü, tarihsel oran görüntüleme ve trend analizi özelliklerine sahip bir mobil uygulamadır. Uygulama, kullanıcıların farklı para birimleri arasında dönüşüm yapmasını, geçmiş döviz kurlarını incelemesini ve döviz trendlerini analiz etmesini sağlamayı amaçlar.

## 2. Hedefler ve Kapsam
- **Hedef:**  
  Kullanıcı dostu, hızlı ve güvenilir bir döviz dönüştürücü uygulaması oluşturmak.
- **Kapsam:**  
  - Güncel döviz kurlarını gerçek zamanlı olarak göstermek.
  - Tarihsel döviz kurlarını sunmak.
  - Seçilen tarih aralıklarına göre trend analizi yapmak.
  - Hata yönetimi ve yüklenme animasyonları ile kullanıcı deneyimini iyileştirmek.

## 3. Temel Özellikler
### 3.1 Döviz Dönüştürücü
- **Para Birimi Seçimi:**  
  Kullanıcı kaynak ve hedef para birimlerini seçer.
- **Miktar Girişi:**  
  Dönüştürmek istenen miktar girilir.
- **API Entegrasyonu:**  
  - `https://api.frankfurter.dev/v1/latest?base={kaynak}&symbols={hedef}` endpoint’i kullanılarak en güncel kurlar alınır.
  - Örnek API Yanıtı:
    ```json
    {
      "base": "USD",
      "date": "2025-03-17",
      "rates": {
        "EUR": 0.92
      }
    }
    ```
- **Sonuç Hesaplama:**  
  Girilen miktar, API tarafından dönen döviz kuru ile çarpılarak sonuç ekranda gösterilir.

### 3.2 Tarihsel Veriler ve Trend Analizi
- **Tarih Seçimi:**  
  Kullanıcı belirli bir tarih veya tarih aralığı seçer.
  - Tek tarih örneği: `https://api.frankfurter.dev/v1/1999-01-04`
  - Tarih aralığı örneği: `https://api.frankfurter.dev/v1/2000-01-01..2000-12-31`
- **Para Birimi Filtreleme:**  
  Temel para birimi değiştirme ve hedef para birimlerini filtreleme (ör. `?base=USD&symbols=EUR`) desteği.
- **Trend Görselleştirme:**  
  Tarihsel veriler grafik veya liste şeklinde sunulacak.

### 3.3 Desteklenen Para Birimleri
- Uygulama, `https://api.frankfurter.dev/v1/currencies` endpoint’i ile desteklenen para birimlerini ve tam isimlerini listeleyecektir.
- Bu veri, kullanıcı arayüzündeki dropdown menülerde kullanılacaktır.

## 4. Teknik Mimari
### 4.1 Katmanlı Mimari (Clean Architecture)
- **Data Katmanı:**
  - **Models:** API’den dönen JSON verisinin Dart modellerine dönüştürülmesi.
  - **Services:** `CurrencyApiService` gibi sınıflarla API isteklerinin yapılması.
  - **Repositories:** Data katmanında domain için repository arayüzlerinin implementasyonu.
- **Domain Katmanı:**
  - **Entities:** `Currency`, `ExchangeRate` gibi temel iş nesneleri.
- **Presentation Katmanı:**
  - **State Management:** BLoC, Provider veya Riverpod kullanımı.
  - **Views & Widgets:** Ana ekran, tarihsel veriler ekranı, hata yönetimi ve yükleme animasyonları.

## 5. Uygulama Akışı
```plaintext
[ Uygulama Açılışı ]
         │
         ▼
[ Para Birimleri Yüklenir (Currencies API) ]
         │
         ▼
[ Ana Ekran: Döviz Dönüştürücü ]
         │
         ├── Kullanıcı: Kaynak & Hedef para birimi seçimi yapar
         ├── Kullanıcı: Miktar girer
         ├── Kullanıcı: "Dönüştür" butonuna basar
         │        │
         │        ▼
         │  [ API çağrısı: latest?base={}&symbols={} ]
         │        │
         │        ▼
         │  [ Hesaplama: Miktar * Döviz kuru ]
         │        │
         │        ▼
         │  [ Sonuç Ekranda Gösterilir ]
         │
         └── Kullanıcı: "Tarihsel Veriler / Trend Analizi" butonuna basar
                        │
                        ▼
          [ Tarihsel Veriler Ekranı ]
                        │
                        ├── Kullanıcı: Tarih veya tarih aralığı seçer
                        ├── Kullanıcı: (Opsiyonel) para birimi filtreleme yapar
                        │        │
                        │        ▼
                        │  [ API çağrısı: Tarih/Tarih Aralığı endpoint'i ]
                        │        │
                        │        ▼
                        │  [ Veriler Liste veya Grafik Olarak Gösterilir ]
                        │
                        └── Hata Yönetimi & Yüklenme Göstergesi
