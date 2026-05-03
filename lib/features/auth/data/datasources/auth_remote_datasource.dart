import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> register(RegisterRequest request);
  Future<String> forgotPassword(ForgotPasswordRequest request);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioConsumer _dioConsumer;

  const AuthRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _dioConsumer = dioConsumer;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.login,
        data: request.toJson(),
      );

      return LoginResponse.fromJson(_asMap(response.data));
    } on DioException catch (error, stackTrace) {
      log('Login request failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.register,
        data: request.toJson(),
      );

      return LoginResponse.fromJson(_asMap(response.data));
    } on DioException catch (error, stackTrace) {
      log('Register request failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<String> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.forgotPassword,
        data: request.toJson(),
      );

      final body = _asMap(response.data);
      final directMessage = body['message']?.toString();
      if (directMessage != null && directMessage.isNotEmpty) {
        return directMessage;
      }

      final data = _asMap(body['data']);
      final nestedMessage = data['message']?.toString();
      if (nestedMessage != null && nestedMessage.isNotEmpty) {
        return nestedMessage;
      }

      return 'Password reset instructions were sent successfully.';
    } on DioException catch (error, stackTrace) {
      log(
        'Forgot password request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioConsumer.get(Endpoints.userProfile);
      final body = _asMap(response.data);
      final payload = _extractUserPayload(body);

      return UserModel.fromJson(payload);
    } on DioException catch (error, stackTrace) {
      log(
        'Get current user request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioConsumer.post(Endpoints.logout);
    } on DioException catch (error, stackTrace) {
      log('Logout request failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error));
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractUserPayload(Map<String, dynamic> body) {
    final directUser = body['user'];
    if (directUser is Map<String, dynamic>) {
      return directUser;
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final nestedUser = data['user'];
      if (nestedUser is Map<String, dynamic>) {
        return nestedUser;
      }

      return data;
    }

    return body;
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    final map = _asMap(data);
    final directMessage = map['message']?.toString();
    if (directMessage != null && directMessage.isNotEmpty) {
      return directMessage;
    }

    final errors = map['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The server took too long to respond. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your internet connection.';
    }

    return error.message ?? 'Authentication request failed.';
  }
}
