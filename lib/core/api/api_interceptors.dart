import 'package:dio/dio.dart';

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authorization header if token exists
    // options.headers['Authorization'] = 'Bearer ${getToken()}';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle successful responses
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle errors globally
    if (err.response?.statusCode == 401) {
      // Handle unauthorized
    }
    super.onError(err, handler);
  }
}
