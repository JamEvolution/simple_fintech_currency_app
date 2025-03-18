
/// UI state durumlarını temsil eden abstract sınıf
abstract class UIState<T> {
  const UIState();

  /// İlk durum olup olmadığını kontrol eder
  bool get isInitial => this is Initial<T>;

  /// Yükleniyor durumunda olup olmadığını kontrol eder
  bool get isLoading => this is Loading<T>;

  /// Veri içerip içermediğini kontrol eder
  bool get hasData => this is Data<T>;

  /// Hata içerip içermediğini kontrol eder
  bool get hasError => this is Error<T>;

  /// Veriyi döndürür, yoksa null döner
  T? get dataOrNull => this is Data<T> ? (this as Data<T>).data : null;

  /// Hatayı döndürür, yoksa null döner
  Exception? get errorOrNull => this is Error<T> ? (this as Error<T>).error : null;

  /// UI state türüne göre farklı değerler döndürür
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Exception error) error,
  }) {
    if (this is Initial<T>) {
      return initial();
    } else if (this is Loading<T>) {
      return loading();
    } else if (this is Data<T>) {
      return data((this as Data<T>).data);
    } else if (this is Error<T>) {
      return error((this as Error<T>).error);
    }
    
    throw StateError('Unknown state type: $this');
  }

  /// UI state türüne göre farklı değerler döndürür, belirtilmeyen durumlar için orElse kullanılır
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(Exception error)? error,
    required R Function() orElse,
  }) {
    if (this is Initial<T> && initial != null) {
      return initial();
    } else if (this is Loading<T> && loading != null) {
      return loading();
    } else if (this is Data<T> && data != null) {
      return data((this as Data<T>).data);
    } else if (this is Error<T> && error != null) {
      return error((this as Error<T>).error);
    }
    
    return orElse();
  }
}

/// İlk durum
class Initial<T> extends UIState<T> {
  const Initial();
}

/// Yükleniyor durumu
class Loading<T> extends UIState<T> {
  const Loading();
}

/// Veri durumu
class Data<T> extends UIState<T> {
  final T data;
  
  const Data(this.data);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Data<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

/// Hata durumu
class Error<T> extends UIState<T> {
  final Exception error;
  
  const Error(this.error);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Error<T> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
} 