import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/shipping_rate_model.dart';

abstract class ShippingRemoteDataSource {
  Future<ShippingRateModel> calculateShipping({
    required String city,
    String? streetAddress,
  });
}

class ShippingRemoteDataSourceImpl implements ShippingRemoteDataSource {
  final DioConsumer _dioConsumer;

  const ShippingRemoteDataSourceImpl({required DioConsumer dioConsumer})
      : _dioConsumer = dioConsumer;

  @override
  Future<ShippingRateModel> calculateShipping({
    required String city,
    String? streetAddress,
  }) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.calculateShipping,
        data: {
          'city': city,
          if (streetAddress != null && streetAddress.isNotEmpty)
            'streetAddress': streetAddress,
        },
      );

      final Map<String, dynamic> body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data as Map)
              : <String, dynamic>{});

      return ShippingRateModel.fromJson(body);
    } on DioException catch (error, stackTrace) {
      log('Calculate shipping failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error));
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return error.message ?? 'Failed to calculate shipping.';
  }
}
