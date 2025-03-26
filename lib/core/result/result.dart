import '../errors/app_exceptions.dart';

/// Bir işlemin sonucunu işlemek için genel bir sonuç sınıfı
class Result<T> {
  final T? data;
  final AppException? error;
  final bool isSuccess;

  Result._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  /// Başarılı bir sonuç oluşturur
  factory Result.success(T data) {
    return Result._(
      data: data,
      isSuccess: true,
    );
  }

  /// Başarısız bir sonuç oluşturur
  factory Result.failure(AppException error) {
    return Result._(
      error: error,
      isSuccess: false,
    );
  }

  /// Başarılı sonuç ise veriyi almak veya işlemek için
  R handle<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onFailure(error!);
    }
  }

  /// Sonucu başka bir değere dönüştürmek için
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      try {
        final transformedData = transform(data as T);
        return Result.success(transformedData);
      } catch (e) {
        if (e is AppException) {
          return Result.failure(e);
        }
        return Result.failure(UnknownException(e));
      }
    } else {
      return Result.failure(error!);
    }
  }

  /// Async dönüştürme işlemi için
  Future<Result<R>> asyncMap<R>(Future<R> Function(T data) transform) async {
    if (isSuccess) {
      try {
        final transformedData = await transform(data as T);
        return Result.success(transformedData);
      } catch (e) {
        if (e is AppException) {
          return Result.failure(e);
        }
        return Result.failure(UnknownException(e));
      }
    } else {
      return Result.failure(error!);
    }
  }

  /// Başarılı sonuç ise veriyi döndürür, değilse hatayı fırlatır
  T getOrThrow() {
    if (isSuccess) {
      return data as T;
    } else {
      throw error!;
    }
  }

  /// Başarılı sonuç ise veriyi döndürür, değilse varsayılan değeri döndürür
  T getOrDefault(T defaultValue) {
    if (isSuccess) {
      return data as T;
    } else {
      return defaultValue;
    }
  }
}

/// Future<Result<T>> dönüştürme yardımcı sınıfı
extension FutureResultExtension<T> on Future<T> {
  /// Future<T> tipini Future<Result<T>> tipine dönüştürür
  Future<Result<T>> asResult() async {
    try {
      final data = await this;
      return Result.success(data);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownException(e));
    }
  }
}

/// Future<Result<T>> tipine eklentiler
extension FutureResultExtensions<T> on Future<Result<T>> {
  /// Sonucu işlemek için
  Future<R> handleResult<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onFailure,
  }) async {
    final result = await this;
    return result.handle(
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
  }
} 