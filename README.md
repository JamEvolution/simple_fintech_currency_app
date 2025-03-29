# Döviz Dönüştürücü

Flutter ile geliştirilmiş, temiz mimari prensiplerini kullanan bir döviz çevirici uygulaması. Bu uygulama, güncel ve geçmiş döviz kurlarını göstermenin yanı sıra farklı para birimleri arasında dönüşüm yapma imkanı sağlar.

## Gif

![Uygulama Demo](assets/simple_fintech_currency_gif.gif)


## Özellikler

- Para birimleri arasında döviz çevirme
- Geçmiş kur verilerini görüntüleme
- Grafik arayüzü ile kur değişimlerini analiz etme
- Sade ve kullanıcı dostu arayüz

## Teknik Gereksinimler

- **Flutter Versiyonu**: 3.27.3
- **Dart Versiyonu**: 3.6.1
- **SDK Kısıtlaması**: sdk: '>=3.0.0 <4.0.0'
- **Sadece Android**: Debug ve test işlemleri şu an sadece Android platformunda yapılmaktadır

## API Kullanımı

Bu uygulama Frankfurter API servisini kullanarak döviz kurlarını almaktadır. API'nin base URL'i: `https://api.frankfurter.dev/v1/`

### API Endpoint'leri

| Endpoint | URL | Açıklama | Parametreler |
|----------|-----|----------|-------------|
| Tüm Kurlar | `/latest` | En güncel döviz kurları | `from`: (opsiyonel) Baz para birimi<br>`to`: (opsiyonel) Dönüştürülecek para birimleri |
| Belirli Tarih | `/:date` | Belirli bir tarihteki döviz kurları | `:date`: Tarih (YYYY-MM-DD formatında)<br>`from`: (opsiyonel) Baz para birimi<br>`to`: (opsiyonel) Dönüştürülecek para birimleri |
| Tarih Aralığı | `/:start_date...:end_date` | Belirli tarih aralığındaki kurlar | `:start_date`: Başlangıç tarihi (YYYY-MM-DD)<br>`:end_date`: Bitiş tarihi (YYYY-MM-DD)<br>`from`: (opsiyonel) Baz para birimi<br>`to`: (opsiyonel) Dönüştürülecek para birimleri |
| Para Birimleri | `/currencies` | Desteklenen para birimlerinin listesi | - |

### Örnek API Sorguları

```
# En güncel EUR kurlarını al
https://api.frankfurter.dev/v1/latest?from=EUR

# EUR'dan USD ve TRY'ye güncel kurları al
https://api.frankfurter.dev/v1/latest?from=EUR&to=USD,TRY

# Belirli bir tarihteki USD kurlarını al
https://api.frankfurter.dev/v1/2023-01-01?from=USD

# EUR'dan USD'ye son 1 aylık kurları al
https://api.frankfurter.dev/v1/2023-01-01..2023-01-31?from=EUR&to=USD
```

### API Yanıt Örnekleri

#### Güncel Kurlar

```json
{
  "amount": 1.0,
  "base": "EUR",
  "date": "2023-04-14",
  "rates": {
    "USD": 1.0977,
    "TRY": 21.352,
    "GBP": 0.88295
  }
}
```

#### Para Birimleri Listesi

```json
{
  "AUD": "Australian Dollar",
  "BGN": "Bulgarian Lev",
  "EUR": "Euro",
  "TRY": "Turkish Lira",
  "USD": "US Dollar"
  // ... diğer para birimleri
}
```

### API İstemcisi

Uygulamada Dio kullanılarak merkezi bir API istemcisi oluşturulmuştur:

```dart
// lib/core/network/api_client.dart
class ApiClient {
  final Dio _dio;
  
  ApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConstants.baseUrl; // https://api.frankfurter.dev/v1/
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // Interceptor'lar
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (log) => AppLogger.d(log.toString()),
    ));
  }
  
  // GET isteği
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Error handling
  Exception _handleError(dynamic error) {
    // Hata işleme...
  }
}
```

## Teknik Özellikler

### Mimari
Uygulama, Clean Architecture prensiplerine göre tasarlanmıştır:

- **Presentation**: Ekranlar, widget'lar ve controller'lar
- **Domain**: Veri modelleri ve repository arayüzleri 
- **Data**: Repository implementasyonları ve veri kaynakları

### Kullanılan Teknolojiler

- **State Yönetimi**: Riverpod (StateNotifier pattern)
- **Ağ İstekleri**: Dio
- **Loglama**: Logger
- **Grafik**: fl_chart
- **Kod Üretimi**: 
  - build_runner
  - freezed (immutable veri modelleri için)
  - json_serializable (JSON serialize/deserialize için)

### Kod Üretimi ve Build Runner

Proje, model sınıflarının ve serialization kodunun otomatik olarak üretilmesi için build_runner kullanmaktadır:

```bash
# Kod üretimi için çalıştırılacak komut
flutter pub run build_runner build --delete-conflicting-outputs

# Sürekli izleme modu için
flutter pub run build_runner watch --delete-conflicting-outputs
```


#### UIState Pattern

UI durumlarını tutarlı şekilde yönetmek için `UIState` sınıfını kullanır:

```dart
// UI durumlarını temsil eden yapı
abstract class UIState<T> {
  // Initial, Loading, Data, Error durumları
  
  // Pattern matching ile kolay kullanım
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Exception error) error,
  });
}
```

#### Controller Pattern

Riverpod ve StateNotifier ile iş mantığını UI'dan ayırır:

```dart
final currencyConverterControllerProvider =
    StateNotifierProvider<CurrencyConverterController, CurrencyConverterState>(
  (ref) => CurrencyConverterController(
    repository: ref.watch(currencyRepositoryProvider),
  ),
);
```

#### Hata Yönetimi

- Özel `AppException` hiyerarşisi ile hata türlerini kategorize eder
- `ErrorHandler` ile uygulama genelinde hata yakalama
- `Result<T>` ile işlem sonuçlarını sarar

#### Kapsamlı Loglama

`AppLogger` sınıfı ile tüm uygulama genelinde tutarlı loglama:

```dart
// Log seviyeleri
AppLogger.d('Debug mesajı');
AppLogger.i('Bilgi mesajı');
AppLogger.w('Uyarı mesajı');
AppLogger.e('Hata mesajı');
```

## Klasör Yapısı

```
lib/
├── core/                    # Çekirdek bileşenler
│   ├── config/              # Uygulama yapılandırması
│   ├── constants/           # Sabitler
│   ├── errors/              # Hata yönetimi
│   ├── network/             # Ağ katmanı
│   ├── state/               # Durum yönetimi
│   ├── utils/               # Yardımcı metotlar
│   └── cache/               # Önbellek yönetimi
│
└── features/                # Uygulama özellikleri
    └── currency_converter/  # Döviz çevirici özelliği
        ├── data/            # Veri katmanı 
        ├── domain/          # Domain katmanı
        └── presentation/    # Sunum katmanı
            ├── controllers/ # İş mantığı
            ├── screens/     # Ekranlar
            └── widgets/     # Bileşenler
```

## Geliştirebilecek Alanlar

- Tema desteği
- Offline mod
- Ayarlar sayfası
- Birim testleri
- Favori para birimleri
- Lokalizasyon desteği
- iOS platformu desteği
