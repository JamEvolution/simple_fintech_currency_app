import '../errors/app_exceptions.dart';

/// UI durumlarını temsil eden sealed class
abstract class UIState<T> {
  const UIState();
  
  /// Başlangıç durumu
  const factory UIState.initial() = Initial;
  
  /// Yükleniyor durumu
  const factory UIState.loading() = Loading;
  
  /// Veri içeren durum
  const factory UIState.data(T data) = Data;
  
  /// Hata durumu
  const factory UIState.error(AppException error) = Error;
  
  /// UI state durumunu kontrol eden yardımcı metotlar
  bool get isInitial => this is Initial<T>;
  bool get isLoading => this is Loading<T>;
  bool get hasData => this is Data<T>;
  bool get hasError => this is Error<T>;
  
  /// Veriyi getter olarak almak
  T? get dataOrNull => this is Data<T> ? (this as Data<T>).data : null;
  
  /// Hatayı getter olarak almak
  AppException? get errorOrNull => this is Error<T> ? (this as Error<T>).error : null;
  
  /// Pattern matching için when metodu
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(AppException error) error,
  }) {
    final state = this;
    if (state is Initial<T>) {
      return initial();
    } else if (state is Loading<T>) {
      return loading();
    } else if (state is Data<T>) {
      return data(state.data);
    } else if (state is Error<T>) {
      return error(state.error);
    } else {
      throw StateError('Unsupported state type: $this');
    }
  }
  
  /// Optional pattern matching
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(AppException error)? error,
    required R Function() orElse,
  }) {
    final state = this;
    if (state is Initial<T> && initial != null) {
      return initial();
    } else if (state is Loading<T> && loading != null) {
      return loading();
    } else if (state is Data<T> && data != null) {
      return data(state.data);
    } else if (state is Error<T> && error != null) {
      return error(state.error);
    } else {
      return orElse();
    }
  }
}

/// Başlangıç durumu
class Initial<T> extends UIState<T> {
  const Initial();
}

/// Yükleniyor durumu
class Loading<T> extends UIState<T> {
  const Loading();
}

/// Veri içeren durum
class Data<T> extends UIState<T> {
  final T data;
  const Data(this.data);
}

/// Hata durumu
class Error<T> extends UIState<T> {
  final AppException error;
  const Error(this.error);
} 