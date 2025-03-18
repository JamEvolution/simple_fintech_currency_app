import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio _dio;
  
  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Bağlantı zaman aşımına uğradı');
      case DioExceptionType.receiveTimeout:
        return Exception('Sunucu yanıt vermedi');
      case DioExceptionType.badResponse:
        return Exception('Sunucu hatası: ${error.response?.statusCode}');
      default:
        return Exception('Bir hata oluştu: ${error.message}');
    }
  }
} 