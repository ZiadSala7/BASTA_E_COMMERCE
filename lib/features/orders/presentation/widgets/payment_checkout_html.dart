import 'dart:convert';

import '../../domain/entities/payment_session_entity.dart';
import 'payment_webview_config.dart';

String buildPaymentCheckoutHtml({
  required String orderId,
  required PaymentSessionEntity session,
  required double amount,
  String currency = PaymentWebViewConfig.currency,
  String merchantName = PaymentWebViewConfig.merchantName,
  String merchantAddress = PaymentWebViewConfig.merchantAddress,
  String orderDescription = PaymentWebViewConfig.orderDescription,
  String scriptUrl = PaymentWebViewConfig.scriptUrl,
}) {
  final sessionId = jsonEncode(session.sessionId);
  final encodedOrderId = jsonEncode(orderId);
  final formattedAmount = amount.toStringAsFixed(2);
  final encodedCurrency = jsonEncode(currency);
  final encodedMerchantName = jsonEncode(merchantName);
  final encodedMerchantAddress = jsonEncode(merchantAddress);
  final encodedOrderDescription = jsonEncode(orderDescription);
  final encodedScriptUrl = jsonEncode(scriptUrl);

  return '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Mastercard Payment</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    html, body {
      min-height: 100%;
      background-color: #ffffff;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      color: #1f2937;
    }
    .loading-container {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 24px;
      text-align: center;
    }
    .spinner {
      width: 44px;
      height: 44px;
      border: 4px solid #e5e7eb;
      border-top-color: #0b9380;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
      margin-bottom: 16px;
    }
    @keyframes spin {
      to { transform: rotate(360deg); }
    }
    .loading-text {
      font-size: 15px;
      font-weight: 600;
      color: #4b5563;
    }
    #error-msg {
      margin-top: 12px;
      color: #dc2626;
      font-size: 14px;
      max-width: 300px;
      line-height: 1.4;
      display: none;
    }
    #embed-target {
      width: 100%;
      min-height: 400px;
    }
  </style>
</head>
<body>
  <div class="loading-container" id="loader">
    <div class="spinner"></div>
    <p class="loading-text">جارٍ فتح بوابة الدفع الآمنة...</p>
    <p class="loading-text" style="font-size: 13px; color: #9ca3af; margin-top: 4px;">Opening secure payment gateway...</p>
    <p id="error-msg"></p>
  </div>
  <div id="embed-target"></div>

  <script>
    var mpgsSessionId = $sessionId;
    var mpgsOrderId = $encodedOrderId;
    var mpgsOrderAmount = '$formattedAmount';
    var mpgsOrderCurrency = $encodedCurrency;
    var mpgsMerchantName = $encodedMerchantName;
    var mpgsMerchantAddress = $encodedMerchantAddress;
    var mpgsOrderDescription = $encodedOrderDescription;
    var mpgsScriptUrl = $encodedScriptUrl;

    function log(msg) {
      if (window.JsLog && window.JsLog.postMessage) {
        window.JsLog.postMessage(msg);
      } else {
        console.log(msg);
      }
    }

    function notify(event, message) {
      log('notify: ' + event + ' | message: ' + message);
      if (window.PaymentBridge && window.PaymentBridge.postMessage) {
        window.PaymentBridge.postMessage(JSON.stringify({ event: event, message: message || '' }));
      } else {
        log('PaymentBridge not available');
      }
    }

    function completed(resultIndicator) {
      log('completed callback triggered: ' + JSON.stringify(resultIndicator));
      var indicator = '';
      if (typeof resultIndicator === 'string') {
        indicator = resultIndicator;
      } else if (resultIndicator && typeof resultIndicator === 'object') {
        indicator = resultIndicator.resultIndicator || resultIndicator.successIndicator || JSON.stringify(resultIndicator);
      }
      notify('completed', indicator);
    }

    function cancelled() {
      log('cancelled callback triggered');
      notify('cancelled', '');
    }

    function failed(error) {
      var message = typeof error === 'string' ? error : (error && error.message ? error.message : JSON.stringify(error || {}));
      log('failed callback triggered: ' + message);
      var errEl = document.getElementById('error-msg');
      if (errEl) {
        errEl.innerText = message;
        errEl.style.display = 'block';
      }
      notify('failed', message);
    }

    function timeout() {
      log('timeout callback triggered');
      failed('Payment request timed out. Please try again.');
    }

    // Expose all callback names expected by Mastercard Hosted Checkout
    window.completeCallback = completed;
    window.cancelCallback = cancelled;
    window.errorCallback = failed;
    window.timeoutCallback = timeout;
    window.completed = completed;
    window.cancelled = cancelled;
    window.failed = failed;

    function openCheckout() {
      log('openCheckout called, Checkout type: ' + (typeof Checkout));
      if (typeof Checkout === 'undefined') {
        failed('Mastercard Checkout SDK not available.');
        return;
      }

      try {
        var config = {
          session: {
            id: mpgsSessionId
          }
        };

        if (mpgsOrderId && mpgsOrderId.length > 0) {
          config.order = {
            id: mpgsOrderId,
            amount: mpgsOrderAmount,
            currency: mpgsOrderCurrency,
            description: mpgsOrderDescription
          };
        }

        config.interaction = {
          merchant: {
            name: mpgsMerchantName,
            address: {
              line1: mpgsMerchantAddress
            }
          },
          displayControl: {
            billingAddress: 'HIDE',
            shipping: 'HIDE'
          }
        };

        log('Calling Checkout.configure');
        var configureResult = Checkout.configure(config);

        function displayPaymentPage() {
          log('Invoking payment display method');
          try {
            if (typeof Checkout.showPaymentPage === 'function') {
              Checkout.showPaymentPage();
            } else if (typeof Checkout.showLightbox === 'function') {
              Checkout.showLightbox();
            } else if (typeof Checkout.showEmbeddedPage === 'function') {
              Checkout.showEmbeddedPage('#embed-target');
            } else {
              failed('No supported display method on Checkout SDK');
            }
          } catch (showErr) {
            log('Checkout display exception: ' + showErr);
            failed(showErr && showErr.message ? showErr.message : String(showErr));
          }
        }

        if (configureResult && typeof configureResult.then === 'function') {
          configureResult.then(function() {
            log('Checkout.configure promise resolved');
            displayPaymentPage();
          }).catch(function(err) {
            log('Checkout.configure promise rejected: ' + JSON.stringify(err));
            failed(err && err.message ? err.message : JSON.stringify(err));
          });
        } else {
          displayPaymentPage();
        }
      } catch (err) {
        log('Checkout.configure exception: ' + err);
        failed(err && err.message ? err.message : String(err));
      }
    }

    function loadMpgsSdk() {
      log('Loading MPGS SDK from: ' + mpgsScriptUrl);
      var script = document.createElement('script');
      script.src = mpgsScriptUrl;
      script.setAttribute('data-error', 'failed');
      script.setAttribute('data-cancel', 'cancelled');
      script.setAttribute('data-complete', 'completed');
      script.setAttribute('data-timeout', 'timeout');
      script.onload = function() {
        log('MPGS script loaded successfully');
        setTimeout(openCheckout, 300);
      };
      script.onerror = function(err) {
        log('MPGS script load error: ' + JSON.stringify(err));
        failed('Failed to load payment gateway script. Please check your internet connection.');
      };
      document.head.appendChild(script);
    }

    log('Payment HTML page ready');
  </script>
</body>
</html>
''';
}
