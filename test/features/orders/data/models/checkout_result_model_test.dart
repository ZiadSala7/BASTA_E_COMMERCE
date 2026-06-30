import 'package:busta/features/orders/data/models/checkout_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckoutResultModel', () {
    test('parses the MPGS checkout response documented by the backend', () {
      final result = CheckoutResultModel.fromJson({
        'status': 'success',
        'message': 'Order created',
        'data': {
          'order': {
            'id': 'order-uuid',
            'totalAmount': '42.50',
            'paymentStatus': 'PENDING',
            'paymentMethod': 'CARD',
          },
          'paymentSession': {
            'sessionId': 'SESSION0001',
            'successIndicator': 'indicator',
            'version': '61',
          },
        },
      });

      expect(result.order.id, 'order-uuid');
      expect(result.order.total, 42.5);
      expect(result.order.paymentStatus, 'PENDING');
      expect(result.paymentSession?.sessionId, 'SESSION0001');
      expect(result.paymentSession?.isValid, isTrue);
      expect(result.message, 'Order created');
    });

    test('supports a session id returned as id', () {
      final result = CheckoutResultModel.fromJson({
        'order': {'id': 'order-uuid', 'amount': 10},
        'paymentSession': {'id': 'SESSION0002'},
      });

      expect(result.paymentSession?.sessionId, 'SESSION0002');
      expect(result.paymentSession?.isValid, isTrue);
    });
  });
}
