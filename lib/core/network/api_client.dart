import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/app_exceptions.dart';

class ApiClient {
  final Dio _dio;
  
  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  )) {
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log request
          _logRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response
          _logResponse(response);
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // Log error
          _logError(error);
          return handler.next(error);
        },
      ),
    );
    
    // Retry interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          if (_shouldRetry(error)) {
            try {
              // Retry the request
              final options = error.requestOptions;
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } on DioException catch (e) {
              return handler.next(e);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           (error.error is SocketException);
  }
  
  void _logRequest(RequestOptions options) {
    print('┌─────────────────────────────────────────────────────────────────────────────────────────');
    print('│ 🚀 REQUEST: ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      print('│ 📝 Query Params: ${options.queryParameters}');
    }
    print('└─────────────────────────────────────────────────────────────────────────────────────────');
  }
  
  void _logResponse(Response response) {
    print('┌─────────────────────────────────────────────────────────────────────────────────────────');
    print('│ ✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('│ ⏱️ Response Time: ${response.requestOptions.responseType}');
    print('└─────────────────────────────────────────────────────────────────────────────────────────');
  }
  
  void _logError(DioException error) {
    print('┌─────────────────────────────────────────────────────────────────────────────────────────');
    print('│ ❌ ERROR: ${error.type} ${error.requestOptions.uri}');
    print('│ 📄 Message: ${error.message}');
    if (error.response != null) {
      print('│ 🔢 Status Code: ${error.response?.statusCode}');
    }
    print('└─────────────────────────────────────────────────────────────────────────────────────────');
  }
  
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e);
    }
  }
  
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e);
    }
  }
  
  Map<String, dynamic> _handleResponse(Response response) {
    try {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String && response.data.toString().isNotEmpty) {
        throw ParseException('Geçersiz veri formatı: String veri döndü.');
      } else {
        throw ParseException('Geçersiz veri formatı.');
      }
    } catch (e) {
      if (e is AppException) {
        throw e;
      }
      throw ParseException('Veri ayrıştırma hatası: ${e.toString()}');
    }
  }
  
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ConnectionTimeoutException(details: error.message);
        
      case DioExceptionType.receiveTimeout:
        return NetworkException('Sunucu yanıt vermedi', code: 'RECEIVE_TIMEOUT', details: error.message);
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        if (statusCode != null) {
          return BadResponseException(
            statusCode,
            details: data,
          );
        }
        return ServerException('Sunucu hatası', details: data);
        
      case DioExceptionType.cancel:
        return NetworkException('İstek iptal edildi', code: 'REQUEST_CANCELLED');
        
      default:
        if (error.error is SocketException) {
          return NetworkException('İnternet bağlantısı yok', code: 'NO_INTERNET');
        }
        return NetworkException(
          error.message ?? 'Bir ağ hatası oluştu',
          code: 'NETWORK_ERROR',
          details: error.error
        );
    }
  }
} 