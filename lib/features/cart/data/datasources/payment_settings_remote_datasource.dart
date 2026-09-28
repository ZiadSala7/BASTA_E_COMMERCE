import 'dart:developer';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';

abstract class PaymentSettingsRemoteDataSource {
  /// Card (Visa) payment is off by default. It only turns on once the
  /// backend endpoint exists and explicitly returns an enabled flag of 1.
  /// Any failure (endpoint not deployed yet, network error, bad payload)
  /// must resolve to `false`, never throw — this must never block checkout.
  Future<bool> isCardPaymentEnabled();
}

class PaymentSettingsRemoteDataSourceImpl
    implements PaymentSettingsRemoteDataSource {
  final DioConsumer _dioConsumer;

  const PaymentSettingsRemoteDataSourceImpl({required DioConsumer dioConsumer})
      : _dioConsumer = dioConsumer;

  @override
  Future<bool> isCardPaymentEnabled() async {
    try {
      final response = await _dioConsumer.get(Endpoints.cardPaymentEnabled);
      return _parseEnabled(response.data);
    } catch (error, stackTrace) {
      log(
        'Card payment flag unavailable, defaulting to disabled',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  bool _parseEnabled(dynamic body) {
    dynamic value = body;

    if (value is Map && value['data'] != null) {
      value = value['data'];
    }

    if (value is Map) {
      value = value['enabled'] ??
          value['isEnabled'] ??
          value['cardPaymentEnabled'] ??
          value['value'] ??
          value['status'];
    }

    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == '1' || normalized == 'true';
    }

    return false;
  }
}
