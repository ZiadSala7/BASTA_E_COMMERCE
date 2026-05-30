import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/auth_message_response.dart';
import '../models/change_password_request.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/reset_password_request.dart';
import '../models/update_profile_request.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<RegisterResponse> register(RegisterRequest request);
  Future<String> confirmEmail(String token);
  Future<String> resendConfirmation(String email);
  Future<String> forgotPassword(ForgotPasswordRequest request);
  Future<String> resetPassword(ResetPasswordRequest request);
  Future<String> changePassword(ChangePasswordRequest request);
  Future<UserModel> updateProfile(UpdateProfileRequest request);
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
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.register,
        data: request.toJson(),
      );

      return RegisterResponse.fromJson(_asMap(response.data));
    } on DioException catch (error, stackTrace) {
      log(
        'Register request failed: ${_messageFromDio(error)}',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<String> confirmEmail(String token) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.confirmEmail,
        data: {'token': token},
      );

      return AuthMessageResponse.fromJson(_asMap(response.data)).message;
    } on DioException catch (error, stackTrace) {
      log('Confirm email request failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<String> resendConfirmation(String email) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.resendConfirmation,
        data: {'email': email},
      );

      return AuthMessageResponse.fromJson(_asMap(response.data)).message;
    } on DioException catch (error, stackTrace) {
      log(
        'Resend confirmation request failed',
        error: error,
        stackTrace: stackTrace,
      );
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

      return AuthMessageResponse.fromJson(_asMap(response.data)).message;
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
  Future<String> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.resetPassword,
        data: request.toJson(),
      );

      return AuthMessageResponse.fromJson(_asMap(response.data)).message;
    } on DioException catch (error, stackTrace) {
      log(
        'Reset password request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<String> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.changePassword,
        data: request.toJson(),
      );

      return AuthMessageResponse.fromJson(_asMap(response.data)).message;
    } on DioException catch (error, stackTrace) {
      log(
        'Change password request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _dioConsumer.patch(
        Endpoints.profile,
        data: request.toJson(),
      );
      final body = _asMap(response.data);
      final payload = _extractUserPayload(body);

      return UserModel.fromJson(payload);
    } on DioException catch (error, stackTrace) {
      log(
        'Update profile request failed',
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
      return value.map((key, item) => MapEntry(key.toString(), item));
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

    if (errors is Map && errors.isNotEmpty) {
      final firstValue = errors.values.first;
      if (firstValue is List && firstValue.isNotEmpty) {
        return firstValue.first.toString();
      }

      return firstValue.toString();
    }

    final apiError = map['error'];
    if (apiError != null && apiError.toString().isNotEmpty) {
      return apiError.toString();
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
