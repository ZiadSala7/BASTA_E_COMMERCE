import 'dart:convert';

import '../../domain/entities/payment_session_entity.dart';
import 'payment_webview_config.dart';

String buildPaymentCheckoutHtml({
  required String orderId,
  required PaymentSessionEntity session,
  required double amount,
}) {
  final sessionId = jsonEncode(session.sessionId);
  final encodedOrderId = jsonEncode(orderId);
  const currency = PaymentWebViewConfig.currency;
  const merchantName = PaymentWebViewConfig.merchantName;
  const merchantAddress = PaymentWebViewConfig.merchantAddress;
  const script = PaymentWebViewConfig.scriptUrl;
  return '''
<!doctype html><html><head>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
html,body{margin:0;min-height:100%;font-family:Arial;background:#fff}
.loading{min-height:100vh;display:flex;align-items:center;justify-content:center;color:#53646f}
#error{color:#b3261e;font-size:16px;max-width:280px;text-align:center}
</style></head><body><div class="loading"><div>
<p>Opening secure payment...</p>
<p id="error"></p>
</div></div><script>
var mpgsSessionId=$sessionId;
var mpgsOrderId=$encodedOrderId;
var mpgsOrderAmount='${amount.toStringAsFixed(2)}';
var mpgsOrderCurrency='$currency';
var mpgsMerchantName='$merchantName';
var mpgsMerchantAddress='$merchantAddress';
var mpgsScriptUrl='$script';
function log(msg){if(window.JsLog)JsLog.postMessage(msg);else console.log(msg)}
function notify(event,message){
 log('notify: '+event+' '+message);
 if(window.PaymentBridge?.postMessage){
  PaymentBridge.postMessage(JSON.stringify({event,message:message||''}));
 }else{log('PaymentBridge not available')}
}
function completed(resultIndicator){log('completed: '+resultIndicator);notify('completed',resultIndicator)}
function cancelled(){log('cancelled');notify('cancelled')}
function failed(error){
 const message=typeof error==='string'?error:JSON.stringify(error||{});
 log('failed: '+message);
 document.getElementById('error').innerText=message;notify('failed',message);
}
function openCheckout(){
 log('openCheckout, Checkout: '+(typeof Checkout));
 if(typeof Checkout==='undefined'){failed('Checkout SDK not loaded');return}
 try{
  Checkout.configure({
   session:{id:mpgsSessionId},
   order:{
    amount:mpgsOrderAmount,
    currency:mpgsOrderCurrency,
    id:mpgsOrderId
   },
   interaction:{
    merchant:{
     name:mpgsMerchantName,
     address:{line1:mpgsMerchantAddress}
    },
    displayControl:{
     billingAddress:'HIDE',
     shipping:'HIDE'
    }
   }
  }).then(function(){
   log('configure resolved, calling showPaymentPage');
   Checkout.showPaymentPage('CARD');
  }).catch(function(e){
   log('configure rejected: '+JSON.stringify(e));
   failed(e?.message||JSON.stringify(e));
  });
 }catch(error){log('exception: '+error);failed(error?.message||JSON.stringify(error))}
}
function loadMpgsSdk(){
 log('loadMpgsSdk: '+mpgsScriptUrl);
 var s=document.createElement('script');
 s.src=mpgsScriptUrl;
 s.setAttribute('data-error','failed');
 s.setAttribute('data-cancel','cancelled');
 s.onload=function(){log('SDK script loaded');setTimeout(openCheckout,500)};
 s.onerror=function(){log('SDK script load error');failed('Failed to load payment gateway script')};
 document.head.appendChild(s);
}
log('HTML ready, waiting for loadMpgsSdk call');
</script></body></html>
''';
}
