import '../../domain/entities/checkout_result_entity.dart';
import 'order_model.dart';
import 'payment_session_model.dart';

class CheckoutResultModel extends CheckoutResultEntity {
  const CheckoutResultModel({
    required super.order,
    required super.paymentSession,
    required super.message,
  });

  factory CheckoutResultModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final payload = data.isEmpty ? json : data;
    final orderJson = _asMap(payload['order']).isEmpty
        ? payload
        : _asMap(payload['order']);
    final sessionJson = _asMap(payload['paymentSession']);

    return CheckoutResultModel(
      order: OrderModel.fromJson(orderJson),
      paymentSession: sessionJson.isEmpty
          ? null
          : PaymentSessionModel.fromJson(sessionJson),
      message: (json['message'] ?? payload['message'] ?? '').toString(),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }
}
