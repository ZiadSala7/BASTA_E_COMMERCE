import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payment_session_entity.dart';

enum PaymentWebViewOutcome { completed, cancelled, failed }

class PaymentWebViewResult {
  final PaymentWebViewOutcome outcome;
  final String orderId;
  final String? message;

  const PaymentWebViewResult({
    required this.outcome,
    required this.orderId,
    this.message,
  });
}

class PaymentWebViewPage extends StatefulWidget {
  final String orderId;
  final PaymentSessionEntity session;

  const PaymentWebViewPage({
    super.key,
    required this.orderId,
    required this.session,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  static const String _checkoutScriptUrl = String.fromEnvironment(
    'MPGS_CHECKOUT_JS_URL',
    defaultValue:
        'https://test-gateway.mastercard.com/static/checkout/checkout.min.js',
  );

  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasReturnedResult = false;

  @override
  void initState() {
    super.initState();
    _debugLog('Opening MPGS checkout', {
      'orderId': widget.orderId,
      'sessionId': _valuePreview(widget.session.sessionId),
      'successIndicator': _valuePreview(widget.session.successIndicator),
      'version': widget.session.version,
      'scriptUrl': _checkoutScriptUrl,
    });
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _debugLog('WebView page started', {'url': url});
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            _debugLog('WebView page finished', {'url': url});
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            _debugLog('WebView resource error', {
              'isForMainFrame': error.isForMainFrame,
              'errorCode': error.errorCode,
              'description': error.description,
              'url': error.url,
            });
            final isHostedCheckoutScript =
                error.url?.contains('checkout.min.js') ?? false;
            if (error.isForMainFrame == true || isHostedCheckoutScript) {
              _finish(
                PaymentWebViewResult(
                  outcome: PaymentWebViewOutcome.failed,
                  orderId: widget.orderId,
                  message: error.description,
                ),
              );
            }
          },
          onNavigationRequest: (request) {
            _debugLog('WebView navigation request', {'url': request.url});
            final result = _resultFromUrl(request.url);
            if (result != null) {
              _finish(result);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'PaymentBridge',
        onMessageReceived: (message) {
          _debugLog('Payment JS callback', {'message': message.message});
          _finish(_resultFromMessage(message.message));
        },
      )
      ..loadHtmlString(_checkoutHtml(), baseUrl: 'https://bs6a.com');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _finish(
            PaymentWebViewResult(
              outcome: PaymentWebViewOutcome.cancelled,
              orderId: widget.orderId,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.pick(ar: 'الدفع بالبطاقة', en: 'Card payment')),
          leading: IconButton(
            onPressed: () => _finish(
              PaymentWebViewResult(
                outcome: PaymentWebViewOutcome.cancelled,
                orderId: widget.orderId,
              ),
            ),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const LinearProgressIndicator(minHeight: 3),
          ],
        ),
      ),
    );
  }

  PaymentWebViewResult? _resultFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.path.contains('/checkout/callback')) {
      return null;
    }

    final orderId = uri.queryParameters['orderId'] ?? widget.orderId;
    final cancelled = uri.queryParameters['cancelled'] == 'true';
    final error = uri.queryParameters['error'];

    if (cancelled) {
      _debugLog('Payment callback cancelled', {'orderId': orderId});
      return PaymentWebViewResult(
        outcome: PaymentWebViewOutcome.cancelled,
        orderId: orderId,
      );
    }

    if (error != null && error.isNotEmpty) {
      _debugLog('Payment callback failed', {
        'orderId': orderId,
        'error': error,
      });
      return PaymentWebViewResult(
        outcome: PaymentWebViewOutcome.failed,
        orderId: orderId,
        message: error,
      );
    }

    _debugLog('Payment callback completed', {'orderId': orderId});
    return PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.completed,
      orderId: orderId,
    );
  }

  PaymentWebViewResult _resultFromMessage(String message) {
    final parts = message.split(':');
    final event = parts.isEmpty ? '' : parts.first;
    final value = parts.length > 1
        ? parts.sublist(1).join(':')
        : widget.orderId;

    switch (event) {
      case 'cancelled':
        return PaymentWebViewResult(
          outcome: PaymentWebViewOutcome.cancelled,
          orderId: widget.orderId,
        );
      case 'failed':
        return PaymentWebViewResult(
          outcome: PaymentWebViewOutcome.failed,
          orderId: widget.orderId,
          message: value,
        );
      case 'completed':
      default:
        return PaymentWebViewResult(
          outcome: PaymentWebViewOutcome.completed,
          orderId: widget.orderId,
        );
    }
  }

  void _finish(PaymentWebViewResult result) {
    if (_hasReturnedResult || !mounted) return;
    _hasReturnedResult = true;
    _debugLog('Closing payment WebView', {
      'outcome': result.outcome.name,
      'orderId': result.orderId,
      'message': result.message,
    });
    Navigator.of(context).pop(result);
  }

  void _debugLog(String message, Map<String, Object?> data) {
    if (!kDebugMode) return;
    debugPrint('[PaymentWebView] $message');
    debugPrint('[PaymentWebView] $data');
  }

  String _valuePreview(String? value) {
    if (value == null || value.isEmpty) return '<empty>';
    final start = value.length <= 12 ? value : value.substring(0, 12);
    final end = value.length <= 8 ? '' : value.substring(value.length - 8);
    return '$start...$end (${value.length} chars)';
  }

  String _checkoutHtml() {
    final sessionId = jsonEncode(widget.session.sessionId);
    final orderId = jsonEncode(widget.orderId);
    final callbackUrl = jsonEncode(
      Uri.https('bs6a.com', '/checkout/callback', {
        'orderId': widget.orderId,
      }).toString(),
    );
    final scriptUrl = const HtmlEscape().convert(_checkoutScriptUrl);

    return '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="$scriptUrl"
    data-error="errorCallback"
    data-cancel="cancelCallback"
    data-complete="completeCallback"></script>
  <style>
    html, body { margin: 0; min-height: 100%; font-family: Arial, sans-serif; background: #ffffff; }
    .loading { min-height: 100vh; display: flex; align-items: center; justify-content: center; color: #53646f; }
  </style>
</head>
<body>
  <div class="loading">
    <div>
      <p>Opening secure payment...</p>
      <button id="openButton" type="button" onclick="openCheckout()" style="padding:12px 18px;border:0;border-radius:8px;background:#006b5f;color:white;font-weight:700;">
        Open card form
      </button>
      <p id="errorText" style="color:#b3261e;font-size:13px;max-width:280px;"></p>
    </div>
  </div>
  <script>
    var orderId = $orderId;
    var callbackUrl = $callbackUrl;
    var opened = false;

    function completeCallback(resultIndicator, sessionVersion) {
      PaymentBridge.postMessage('completed:' + orderId);
    }

    function cancelCallback() {
      PaymentBridge.postMessage('cancelled:' + orderId);
    }

    function errorCallback(error) {
      var message = typeof error === 'string' ? error : JSON.stringify(error || {});
      document.getElementById('errorText').innerText = message;
      PaymentBridge.postMessage('failed:' + message);
    }

    function openCheckout() {
      if (opened) return;
      opened = true;
      try {
        Checkout.configure({
          session: { id: $sessionId },
          interaction: {
            operation: 'PURCHASE',
            merchant: { name: 'Bs6a' },
            returnUrl: callbackUrl
          }
        });
        Checkout.showLightbox();
      } catch (error) {
        opened = false;
        errorCallback(error && error.message ? error.message : error);
      }
    }

    window.onload = function() {
      setTimeout(openCheckout, 250);
    };
  </script>
</body>
</html>
''';
  }
}
