import 'dart:developer';
import 'package:get_it/get_it.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioConsumer _dioConsumer = GetIt.instance<DioConsumer>();

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final response = await _dioConsumer.post(
        Endpoints.login,
        data: loginRequest.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);
      log('Login successful for user: ${loginResponse.user.email}');
      return loginResponse.user.copyWith(token: loginResponse.token);
    } catch (e) {
      log('Login failed: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        name: name,
      );
      final response = await _dioConsumer.post(
        Endpoints.register,
        data: registerRequest.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);
      log('Registration successful for user: ${loginResponse.user.email}');
      return loginResponse.user.copyWith(token: loginResponse.token);
    } catch (e) {
      log('Registration failed: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    try {
      final response = await _dioConsumer.get(Endpoints.userProfile);
      final user = UserEntity.fromJson(
        response.data['user'] as Map<String, dynamic>,
      );
      log('Fetched current user: ${user.email}');
      return user;
    } catch (e) {
      log('Failed to get current user: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioConsumer.post(Endpoints.logout);
      log('User logged out successfully');
    } catch (e) {
      log('Logout failed: $e');
      rethrow;
    }
  }
}
