import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/coupon_model.dart';

abstract class CouponsRemoteDataSource {
  Future<List<CouponModel>> getMyCoupons({int page = 1, int limit = 50});
}

class CouponsRemoteDataSourceImpl implements CouponsRemoteDataSource {
  final DioConsumer _dioConsumer;

  const CouponsRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _dioConsumer = dioConsumer;

  @override
  Future<List<CouponModel>> getMyCoupons({int page = 1, int limit = 50}) async {
    try {
      final response = await _dioConsumer.get(
        Endpoints.myCoupons,
        queryParameters: {'page': page, 'limit': limit},
      );

      return _parseCoupons(response.data);
    } on DioException catch (error, stackTrace) {
      log(
        'Get my coupons request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_messageFromDio(error));
    }
  }

  List<CouponModel> _parseCoupons(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => CouponModel.fromJson(_asMap(item)))
          .toList();
    }

    if (data is Map) {
      final dataField = data['data'];
      if (dataField is List) {
        return dataField
            .whereType<Map>()
            .map((item) => CouponModel.fromJson(_asMap(item)))
            .toList();
      }

      final itemsField = data['items'] ?? data['coupons'];
      if (itemsField is List) {
        return itemsField
            .whereType<Map>()
            .map((item) => CouponModel.fromJson(_asMap(item)))
            .toList();
      }
    }

    return [];
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

    return error.message ?? 'Failed to load coupons.';
  }
}
