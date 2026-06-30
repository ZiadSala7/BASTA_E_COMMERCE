import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/account_stats_model.dart';

abstract class AccountRemoteDataSource {
  Future<AccountStatsModel> getAccountStats();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final DioConsumer _dioConsumer;

  const AccountRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _dioConsumer = dioConsumer;

  @override
  Future<AccountStatsModel> getAccountStats() async {
    try {
      // Fetch orders count
      final ordersResponse = await _dioConsumer.get(Endpoints.myOrders);
      final ordersCount = _countItems(ordersResponse.data);

      // Fetch favorites count
      final favoritesResponse = await _dioConsumer.get(Endpoints.favorites);
      final favoritesCount = _countItems(favoritesResponse.data);

      // For coupons, we'll use a placeholder count or fetch from available endpoint
      // Since there's no specific coupons endpoint, we'll set it to 0 for now
      const couponsCount = 0;

      return AccountStatsModel(
        ordersCount: ordersCount,
        couponsCount: couponsCount,
        favoritesCount: favoritesCount,
      );
    } on DioException catch (error, stackTrace) {
      log(
        'Get account stats request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_messageFromDio(error));
    }
  }

  int _countItems(dynamic data) {
    if (data is List) return data.length;

    if (data is Map<String, dynamic>) {
      final directData = data['data'];
      if (directData is List) return directData.length;

      if (directData is Map<String, dynamic>) {
        final items =
            directData['items'] ??
            directData['orders'] ??
            directData['favorites'];
        if (items is List) return items.length;
      }

      final items = data['items'] ?? data['orders'] ?? data['favorites'];
      if (items is List) return items.length;
    }

    return 0;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  String _messageFromDio(DioException error) {
    final map = _asMap(error.response?.data);
    final message = map['message']?.toString();
    if (message != null && message.isNotEmpty) return message;

    final apiError = map['error']?.toString();
    if (apiError != null && apiError.isNotEmpty) return apiError;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The server took too long to respond. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your internet connection.';
    }

    return error.message ?? 'Account stats request failed.';
  }
}
