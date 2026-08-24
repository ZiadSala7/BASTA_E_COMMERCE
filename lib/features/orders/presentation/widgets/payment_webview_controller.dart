import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/entities/payment_session_entity.dart';
import '../models/payment_webview_result.dart';
import 'payment_checkout_html.dart';
import 'payment_result_parser.dart';
import 'payment_webview_config.dart';
import 'payment_webview_log.dart';

class PaymentCheckoutController {
  PaymentCheckoutController({
    required this.orderId,
    required this.session,
    required this.totalAmount,
    required this.onLoadingChanged,
    required this.onResult,
  }) {
    webViewController = _createController();
  }

  final String orderId;
  final PaymentSessionEntity session;
  final double totalAmount;
  final void Function(bool) onLoadingChanged;
  final void Function(PaymentWebViewResult) onResult;
  late final WebViewController webViewController;

  WebViewController _createController() {
    logPaymentWebView('Opening MPGS checkout', {'orderId': orderId});

    final gatewayUri = Uri.tryParse(PaymentWebViewConfig.scriptUrl);
    final baseUrl =
        gatewayUri != null &&
            gatewayUri.scheme.isNotEmpty &&
            gatewayUri.host.isNotEmpty
        ? '${gatewayUri.scheme}://${gatewayUri.host}'
        : 'https://test-network.mtf.gateway.mastercard.com';

    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            logPaymentWebView('Page started', {'url': url});
            onLoadingChanged(true);
          },
          onPageFinished: (url) {
            logPaymentWebView('Page finished', {'url': url});
            onLoadingChanged(false);
            _loadSdk();
          },
          onWebResourceError: _handleResourceError,
          onNavigationRequest: _handleNavigation,
        ),
      )
      ..addJavaScriptChannel(
        'PaymentBridge',
        onMessageReceived: (message) {
          logPaymentWebView(
            'Payment JS callback',
            {'message': message.message},
          );
          onResult(paymentResultFromMessage(message.message, orderId));
        },
      )
      ..addJavaScriptChannel(
        'JsLog',
        onMessageReceived: (message) {
          logPaymentWebView('[JS] ${message.message}');
        },
      )
      ..loadHtmlString(
        buildPaymentCheckoutHtml(
          orderId: orderId,
          session: session,
          amount: totalAmount,
        ),
        baseUrl: baseUrl,
      );
  }

  void _loadSdk() {
    logPaymentWebView('Injecting SDK load call');
    webViewController.runJavaScript('loadMpgsSdk()');
  }

  void _handleResourceError(WebResourceError error) {
    logPaymentWebView('WebView resource error', {
      'code': error.errorCode,
      'description': error.description,
      'url': error.url,
      'isForMainFrame': error.isForMainFrame,
    });
    final scriptFailed = error.url?.contains('checkout.min.js') ?? false;
    if (error.isForMainFrame == true || scriptFailed) {
      onResult(
        PaymentWebViewResult(
          outcome: PaymentWebViewOutcome.failed,
          orderId: orderId,
          message: error.description,
        ),
      );
    }
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final result = paymentResultFromUrl(request.url, orderId);
    if (result == null) return NavigationDecision.navigate;
    onResult(result);
    return NavigationDecision.prevent;
  }
}
