# 💳 تقرير فحص ومعالجة عملية الدفع عبر بوابة ماستركارد (MPGS Payment Gateway Technical Report)

---

## 📌 1. الملخص التنفيذي (Executive Summary)

تم اختبار دورة الدفع الإلكتروني بالبطاقة (`CARD`) كاملة من خلال تطبيق Flutter ومطابقتها مع موقع الويب الإنتاجي ([https://bs6a.com/](https://bs6a.com/)).

### التسلسل الذي تم:
1. **إنشاء الطلب (`POST /api/orders/checkout`)**: تم بنجاح (`201 Created`) وأرجع السيرفر بيانات الطلب (`orderId`) وبيانات جلسة ماستركارد (`sessionId: SESSION0002518362202J71246551N8` و `successIndicator`).
2. **فتح صفحة الدفع في التطبيق (`PaymentWebView`)**: تم تحميل مكتبة ماستركارد `checkout.min.js` بنجاح من:
   `https://test-network.mtf.gateway.mastercard.com/static/checkout/checkout.min.js`.
3. **الخطأ الذي ظهر عند تهيئة بوابة الدفع**:
   ```json
   {
     "error": {
       "result": "ERROR",
       "cause": "INVALID_REQUEST",
       "explanation": "order.amount is not allowed via configure()"
     }
   }
   ```
4. **إلغاء الطلب التلقائي (`POST /api/payments/cancel/:orderId`)**: عند فشل فتح بوابة الدفع، قام التطبيق باستدعاء API الإلغاء فوراً لتحرير المخزون (`200 OK`).

---

## 🔍 2. تفاصيل الخطأ وتحليله الفني (Root Cause Analysis)

### ❌ سبب الخطأ:
وفقاً لتوثيق **Mastercard Payment Gateway Services (MPGS) Hosted Checkout**:
* عندما يقوم الـ **Backend** بإنشاء جلسة دفع (`INITIATE_CHECKOUT` / `CREATE_CHECKOUT_SESSION`)، فإن السيرفر يقوم بالفعل بتسجيل المبلغ (`order.amount`) والعملة (`order.currency`) ورقم الطلب (`order.id`) وربطها برقم الجلسة (`sessionId`).
* عند استدعاء دالة التهيئة في الواجهة الأمامية:
  ```javascript
  Checkout.configure({
    session: {
      id: "SESSION0002518362202J71246551N8"
    }
  });
  ```
  **تمنع بوابة ماستركارد أمنياً** إعادة تمرير كائن `order: { amount: ... }` داخل `Checkout.configure()` طالما تم توفير `sessionId`. تمرير المبلغ في هذه المرحلة يعتبره نظام MPGS محاولة تلاعب بالطلب (`INVALID_REQUEST: order.amount is not allowed via configure()`).

### 🌐 مطابقة التحليل مع الكود الفعلي لموقع الإنتاج (`https://bs6a.com/`):
عند فحص ملف `Checkout.js` في موقع الإنتاج، وُجد أن الموقع يقوم بالتهيئة بالتنسيق التالي فقط:
```javascript
// ✅ التنسيق الصحيح المعتمد في الويب
window.Checkout.configure({
  session: {
    id: paymentSession.sessionId
  }
});

window.completeCallback = function(resultIndicator) {
  // التوجيه إلى صفحة التحقق بعد نجاح الدفع
  navigate(`/checkout/callback?orderId=${orderId}&resultIndicator=${resultIndicator}`);
};

window.Checkout.showPaymentPage();
```

---

## 🛠️ 3. الإجراءات والحلول التي تم تطبيقها في التطبيق (Client-side Fixes)

1. **تحديث ملف `payment_checkout_html.dart`**:
   - تم تعديل دالة `openCheckout()` ليتم تمرير `{ session: { id: sessionId } }` فقط إلى `Checkout.configure()` ومطابقة كود موقع الويب بنسبة 100%.
   - تم إزالة `order.amount` من كائن التهيئة في الـ Client Side.

2. **تضمين رقم الهاتف تلقائياً (`Delivery Phone Number`)**:
   - تم حل خطأ `400 Bad Request` السابق ("A valid mobile number is required for delivery") بإضافة حقل رقم الهاتف للتوصيل والتحقق منه وإرساله في `POST /api/orders/checkout`.

---

## 📋 4. التوصيات لمطور الـ Backend (Notes & Recommendations for Backend Developer)

يرجى مراجعة النقاط التالية لضمان سلاسة دورة الدفع:

### 1️⃣ إعداد جلسة الدفع (Session Creation / Checkout Initiation):
تأكد من أن الـ Backend عند إنشاء الجلسة مع MPGS يمرر المعايير التالية بشكل سليم:
* `order.id`: معرف الطلب الفريد.
* `order.amount`: المبلغ الإجمالي (بصيغة `XX.XX` أو `XX.XXX` حسب عملة JOD).
* `order.currency`: العملة (مثال: `JOD`).
* `interaction.operation`: مثل `PURCHASE` أو `AUTHORIZE`.
* `interaction.merchant.name`: اسم المتجر (`Basta` / `بسطة`).
* `interaction.returnUrl`: رابط العودة (في حال استخدام إعادة التوجيه الكاملة).

### 2️⃣ التحقق من حالة الدفع (`GET /api/payments/verify/:orderId`):
* عند عودة المستخدم بنجاح من بوابة ماستركارد ومعه `resultIndicator`، يقوم التطبيق/الموقع باستدعاء:
  `GET /api/payments/verify/:orderId`
* يجب أن يقارن الـ Backend الـ `resultIndicator` مع الـ `successIndicator` المخزن في قاعدة البيانات للجلسة، واستعلام حالة الطلب من MPGS عبر:
  `GET /api/rest/version/XX/merchant/{merchantId}/order/{orderId}`
* إذا كانت الحالة `CAPTURED` أو `SUCCESSFUL`، يتم تحديث `paymentStatus = PAID` و `currentStatus = PROCESSING / CONFIRMED`.
* إذا كانت الاستجابة مؤقتاً `PENDING`، يدعم التطبيق والويب إعادة المحاولة بعد 2.5 ثانية تلقائياً.

### 3️⃣ إلغاء الطلب عند التراجع أو الخطأ (`POST /api/payments/cancel/:orderId`):
* التأكد من أن مسار الإلغاء يعيد عناصر المخزون (`inventory restored`) ويحول حالة الطلب إلى `CANCELLED` وحالة الدفع إلى `FAILED` بنجاح (وهو ما يعمل بشكل ممتاز حالياً في السيرفر).

---

## 🧪 5. سجلات التتبع الكاملة (Raw Technical Logs)

### أ) طلب إنشاء الطلب (Checkout Request):
```http
POST https://api.bs6a.com/api/orders/checkout
Content-Type: application/json
Authorization: Bearer <JWT_TOKEN>

{
  "addressData": {
    "streetAddress": "Pinned delivery location: 31.953900, 35.910600",
    "city": "Amman",
    "state": "Amman",
    "postalCode": "11183",
    "country": "Jordan",
    "phone": "01119692767",
    "latitude": 31.95390010088144,
    "longitude": 35.910600163042545
  },
  "streetAddress": "Pinned delivery location: 31.953900, 35.910600",
  "city": "Amman",
  "state": "Amman",
  "postalCode": "11183",
  "country": "Jordan",
  "paymentMethod": "CARD",
  "phone": "01119692767"
}
```

### ب) استجابة إنشاء الطلب الناجحة (Checkout Response):
```json
{
  "status": "success",
  "message": "Order placed successfully!",
  "data": {
    "order": {
      "id": "2946f85f-2449-49b1-971f-49c85cfa0a6b",
      "customerId": "30c6b0f7-6b72-4a13-ab52-aed09fb061f4",
      "shippingAddressId": "1c27982e-2288-4145-91c3-0b599a7dd4d8",
      "totalAmount": "14.00",
      "shippingCost": "3.00",
      "discountAmount": "0.00",
      "appliedCoupon": null,
      "paymentMethod": "CARD",
      "paymentStatus": "PENDING",
      "currentStatus": "PLACED"
    },
    "paymentSession": {
      "sessionId": "SESSION0002518362202J71246551N8",
      "successIndicator": "0bce271cd2014bef",
      "version": "32de206f01"
    }
  }
}
```

### ج) استجابة بوابة ماستركارد المرفوضة (Mastercard MPGS Error):
```json
{
  "error": {
    "result": "ERROR",
    "cause": "INVALID_REQUEST",
    "explanation": "order.amount is not allowed via configure()"
  }
}
```

### د) استجابة إلغاء الطلب (Cancel Payment Response):
```json
{
  "status": "success",
  "message": "Order cancelled successfully and inventory restored.",
  "order": {
    "id": "2946f85f-2449-49b1-971f-49c85cfa0a6b",
    "paymentMethod": "CARD",
    "paymentStatus": "FAILED",
    "currentStatus": "CANCELLED"
  }
}
```
