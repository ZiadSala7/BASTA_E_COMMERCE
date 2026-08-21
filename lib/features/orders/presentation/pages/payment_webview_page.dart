import 'package:flutter/material.dart';

import '../../domain/entities/payment_session_entity.dart';
import '../models/payment_webview_result.dart';
import '../widgets/payment_webview_body.dart';
import '../widgets/payment_webview_controller.dart';

export '../models/payment_webview_result.dart';

class PaymentWebViewPage extends StatefulWidget {
  const PaymentWebViewPage({
    required this.orderId,
    required this.totalAmount,
    required this.session,
    super.key,
  }) : assert(totalAmount > 0);

  final String orderId;
  final double totalAmount;
  final PaymentSessionEntity session;

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final PaymentCheckoutController _checkout;
  bool _isLoading = true;
  bool _hasReturnedResult = false;

  @override
  void initState() {
    super.initState();
    _checkout = PaymentCheckoutController(
      orderId: widget.orderId,
      session: widget.session,
      totalAmount: widget.totalAmount,
      onLoadingChanged: (value) {
        if (mounted && !_hasReturnedResult) {
          setState(() => _isLoading = value);
        }
      },
      onResult: _finish,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: PaymentWebViewBody(
        controller: _checkout.webViewController,
        isLoading: _isLoading,
        onClose: _cancel,
      ),
    );
  }

  void _cancel() => _finish(
    PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.cancelled,
      orderId: widget.orderId,
    ),
  );

  void _finish(PaymentWebViewResult result) {
    if (_hasReturnedResult || !mounted) return;
    _hasReturnedResult = true;
    Navigator.of(context).pop(result);
  }
}
