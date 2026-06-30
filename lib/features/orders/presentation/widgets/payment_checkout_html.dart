import 'dart:convert';

import '../../domain/entities/payment_session_entity.dart';
import 'payment_webview_config.dart';

String buildPaymentCheckoutHtml({
  required String orderId,
  required double totalAmount,
  required PaymentSessionEntity session,
}) {
  final sessionId = jsonEncode(session.sessionId);
  final encodedOrderId = jsonEncode(orderId);
  final amount = totalAmount.toStringAsFixed(2);
  final currency = jsonEncode(PaymentWebViewConfig.currency);
  final merchant = jsonEncode(PaymentWebViewConfig.merchantName);
  final address = jsonEncode(PaymentWebViewConfig.merchantAddress);
  final description = jsonEncode(PaymentWebViewConfig.orderDescription);
  final callback = jsonEncode(
    Uri.https('bs6a.com', '/checkout/callback', {
      'orderId': orderId,
    }).toString(),
  );
  final script = const HtmlEscape().convert(PaymentWebViewConfig.scriptUrl);
  return '''
<!doctype html><html><head>
<meta name="viewport" content="width=device-width,initial-scale=1">
<script src="$script" data-error="failed" data-cancel="cancelled"
 data-complete="completed"></script>
<style>
html,body{margin:0;min-height:100%;font-family:Arial;background:#fff}
.loading{min-height:100vh;display:flex;align-items:center;justify-content:center;color:#53646f}
button{padding:12px 18px;border:0;border-radius:8px;background:#006b5f;color:#fff;font-weight:700}
#error{color:#b3261e;font-size:13px;max-width:280px}
</style></head><body><div class="loading"><div>
<p>Opening secure payment...</p>
<button onclick="openCheckout()">Open card form</button><p id="error"></p>
</div></div><script>
const orderId=$encodedOrderId, callbackUrl=$callback; let opened=false;
function notify(event,message){
 if(window.PaymentBridge?.postMessage){
  PaymentBridge.postMessage(JSON.stringify({event,message:message||''}));
 }
}
function completed(){notify('completed')}
function cancelled(){notify('cancelled')}
function failed(error){
 const message=typeof error==='string'?error:JSON.stringify(error||{});
 document.getElementById('error').innerText=message;notify('failed',message);
}
function openCheckout(){
 if(opened)return;opened=true;
 try{Checkout.configure({
  session:{id:$sessionId},
  order:{amount:$amount,currency:$currency,description:$description,id:orderId},
  interaction:{operation:'PURCHASE',merchant:{name:$merchant,address:{line1:$address}},
   returnUrl:callbackUrl,displayControl:{billingAddress:'HIDE',shipping:'HIDE'}}
 });Checkout.showLightbox()}
 catch(error){opened=false;failed(error?.message||error)}
}
window.onload=()=>setTimeout(openCheckout,250);
</script></body></html>
''';
}
