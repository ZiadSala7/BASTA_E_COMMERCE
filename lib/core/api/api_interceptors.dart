import 'package:dio/dio.dart';

import '../auth/session_token_store.dart';
import '../di/service_locator.dart';

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (sl.isRegistered<SessionTokenStore>()) {
      final token = await sl<SessionTokenStore>().getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (sl.isRegistered<SessionTokenStore>()) {
        await sl<SessionTokenStore>().clearToken();
      }
    }

    handler.next(err);
  }
}
