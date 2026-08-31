# Payment Integration Guide for Flutter Developers

This document outlines the entire payment process for the e-commerce platform. It details how the Flutter application should interact with the backend APIs to process Cash on Delivery (COD) and Credit Card (MPGS) orders, handle errors, and manage inventory restoration.

## Overview

The platform supports two payment methods:
1. **Cash on Delivery (COD)**: Order is created, inventory is deducted, and the order is immediately dispatched to the shipping provider (Spex).
2. **Credit Card (CARD)**: Uses Mastercard Payment Gateway Services (MPGS). The order is created as `PENDING`, inventory is temporarily reserved, and the user completes the payment via MPGS. Success triggers dispatch; failure/cancellation restores inventory.

---

## 1. Checkout (Order Initialization)

To initiate an order, the Flutter app must call the checkout endpoint.

**Endpoint**: `POST /orders/checkout`  
**Authentication**: Required (Bearer Token)

### Request Payload:
```json
{
    "streetAddress": "King Hussein Street",
    "city": "Amman",
    "state": "Amman Governorate",
    "postalCode": "11110",
    "country": "Jordan",
    "paymentMethod": "CARD", // or "COD"
    "couponCode": "SUMMER20" // Optional
}
```

### Response (If COD):
When `paymentMethod` is `COD`, the order is finalized immediately.
```json
{
    "status": "success",
    "message": "Order placed successfully!",
    "data": {
        "order": {
            "id": "uuid-order-id",
            "currentStatus": "PLACED",
            "paymentStatus": "UNPAID",
            ...
        },
        "paymentSession": null,
        "shippingDispatch": { "success": true, "data": ... }
    }
}
```
**Flutter Action**: Navigate the user to the "Order Success" page.

### Response (If CARD):
When `paymentMethod` is `CARD`, the backend initializes an MPGS session.
```json
{
    "status": "success",
    "message": "Order placed successfully!",
    "data": {
        "order": {
            "id": "uuid-order-id",
            "currentStatus": "PLACED",
            "paymentStatus": "PENDING",
            ...
        },
        "paymentSession": {
            "sessionId": "SESSION0000000000000000000000",
            "successIndicator": "...",
            "version": "72"
        }
    }
}
```
**Flutter Action**: Extract `paymentSession.sessionId` and `order.id` to initiate the Mastercard Payment Gateway (see Step 2).

---

## 2. Mastercard Gateway Integration (CARD Only)

Once you receive the `sessionId` from the checkout endpoint, you need to load the MPGS payment UI. 

For Flutter, you can achieve this by either:
1. Using a **Webview** to load a local/hosted HTML file that runs `checkout.min.js`.
2. Using an official or community Mastercard Gateway SDK for Flutter.

If using a Webview and `checkout.min.js`:
- Inject the `sessionId` into the `Checkout.configure({ session: { id: '<sessionId>' } })` method.
- Catch the callbacks triggered by MPGS (`complete`, `cancel`, `error`).

---

## 3. Post-Payment Callbacks & Verification

The MPGS UI will yield one of three outcomes. The Flutter app **must** catch these and call the appropriate backend endpoints.

### A. Payment Success (`completeCallback`)
When the user successfully pays, MPGS returns a success indicator.

**Endpoint**: `GET /payments/verify/:orderId`  
**Authentication**: Required

**Flutter Action**: 
1. Call this endpoint to tell the backend to verify the transaction with Mastercard server-to-server.
2. The backend will mark the order as `PAID`, deduct the coupon usage, create vendor notifications, and dispatch the order to Spex (shipping).
3. If the backend returns `status: 'success'`, navigate to the "Order Success" screen.

### B. Payment Cancelled (`cancelCallback`)
If the user closes the payment modal, goes back, or abandons the payment.

**Endpoint**: `POST /payments/cancel/:orderId`  
**Authentication**: Required

**Flutter Action**:
1. Call this endpoint immediately.
2. The backend will mark the order as `FAILED` and `CANCELLED`.
3. **Crucial**: The backend will restore the reserved inventory stock for the items in this order.
4. Show a toast/snackbar: "Payment was cancelled."

### C. Payment Error (`errorCallback`)
If the MPGS SDK throws a technical error or the card is heavily declined resulting in an exception.

**Endpoint**: `POST /payments/cancel/:orderId`  
**Authentication**: Required

**Flutter Action**:
1. Call the cancel endpoint to restore stock and fail the order.
2. Show a toast/snackbar: "A payment gateway error occurred, please try again."

---

## 4. App Lifecycle Handling (Edge Cases)

Since mobile apps can be killed or swiped away while the payment screen is open, the system has fallback mechanisms:

1. **Frontend App-Kill Handling**: 
   If possible, hook into Flutter's app lifecycle (`AppLifecycleState.detached` / `inactive`). If there is an active `orderId` pending payment and the user closes the app, attempt to call `POST /payments/cancel/:orderId` in the background.

2. **Backend Webhook Fallback**: 
   Mastercard sends an asynchronous webhook to `POST /payments/webhook`. If the user successfully pays but loses internet before the Flutter app calls the `/verify` endpoint, the backend webhook will catch the payment and process it successfully.

3. **Backend Cron Job (Cleanup)**:
   The backend runs an automated script (`cleanupExpiredPendingOrders`) that looks for `CARD` orders stuck in `PENDING` status for more than **15 minutes**. It automatically cancels them and restores the inventory.

---

## Summary of Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/orders/checkout` | Create order, deduct stock, get MPGS `sessionId`. |
| `GET`  | `/payments/verify/:orderId` | Confirm payment success, dispatch to shipping. |
| `POST` | `/payments/cancel/:orderId` | Cancel abandoned/failed payment, restore stock. |
