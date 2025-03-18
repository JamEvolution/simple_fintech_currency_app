import 'dart:async';
import '../errors/app_exceptions.dart';

class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration timeToLive;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.timeToLive,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > timeToLive;
}

class CacheManager {
  final Map<String, dynamic> _cache = {};
  final Duration defaultTimeToLive;

  // Singleton instance
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;

  CacheManager._internal({this.defaultTimeToLive = const Duration(minutes: 30)});

  /// Veriyi cache'e kaydeder
  void set<T>(String key, T data, {Duration? timeToLive}) {
    final entry = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      timeToLive: timeToLive ?? defaultTimeToLive,
    );
    _cache[key] = entry;
  }

  /// Cache'den veriyi çeker
  T? get<T>(String key) {
    final entry = _cache[key] as CacheEntry<T>?;
    
    if (entry == null) {
      return null;
    }
    
    if (entry.isExpired) {
      remove(key);
      return null;
    }
    
    return entry.data;
  }

  /// Cache'den veriyi siler
  void remove(String key) {
    _cache.remove(key);
  }

  /// Tüm cache'i temizler
  void clear() {
    _cache.clear();
  }

  /// Belirli bir prefix ile başlayan tüm cache'leri temizler
  void clearByPrefix(String prefix) {
    final keysToRemove = _cache.keys.where((key) => key.startsWith(prefix));
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Süresi dolmuş olan tüm cache'leri temizler
  void clearExpired() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    _cache.forEach((key, value) {
      final entry = value as CacheEntry;
      if (now.difference(entry.timestamp) > entry.timeToLive) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Key ve veri sağlayıcı fonksiyon ile veriyi çeker, yoksa kaydeder
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() dataProvider, {
    Duration? timeToLive,
  }) async {
    final cachedData = get<T>(key);
    if (cachedData != null) {
      return cachedData;
    }
    
    try {
      final data = await dataProvider();
      set<T>(key, data, timeToLive: timeToLive);
      return data;
    } catch (e) {
      throw CacheException(
        'Veri kaynağından veri alınırken hata oluştu: ${e.toString()}',
        details: e
      );
    }
  }
} 