import 'package:dio/dio.dart';
import 'api_interceptors.dart';
import 'api_keys.dart';

class DioHelper {
  static Dio? _dio;

  static Dio get dio {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: ApiKeys.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          // Add other default headers if needed
        },
      ),
    );
    return _dio!;
  }

  static void init() {
    // Add interceptors
    dio.interceptors.add(ApiInterceptors());
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }
}
