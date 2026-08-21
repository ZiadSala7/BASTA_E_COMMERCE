# Frontend & Mobile Integration Guide: Checkout & Shipping

This document outlines how the frontend (Web and Flutter) should interact with the backend server during the checkout process. Our backend supports both **Cash on Delivery (COD)** and **Card Payments**, and it handles the shipping logistics (via Spex) automatically.

---

## 1. The Checkout API Request

When a user confirms their cart, you need to call the checkout endpoint (e.g., `POST /api/orders/checkout`). 

**Expected Payload from Frontend:**
```json
{
  "addressData": {
    "streetAddress": "123 Main St",
    "city": "Amman",
    "state": "Amman",
    "postalCode": "11118",
    "country": "Jordan"
  },
  "paymentMethod": "COD", // MUST be exactly "COD" or "CARD"
  "couponCode": "SUMMER20" // Optional
}
```
*(Note: `userId` is extracted automatically from the user's authentication token on the backend).*

---

## 2. Handling the Response (COD vs. CARD)

The backend handles these two payment methods very differently. Your frontend application must inspect the response to determine the next UI step.

### Scenario A: Cash on Delivery (`paymentMethod: "COD"`)

For COD, the backend immediately finalizes the order and automatically dispatches the shipping request to the Spex Delivery API. 

**Backend Response for COD:**
```json
{
  "order": {
    "id": "ord-12345",
    "totalAmount": "150.00",
    "currentStatus": "PLACED",
    // ...other order details
  },
  "paymentSession": null,
  "shippingDispatch": {
    "success": true,
    "data": { ... } // Data from Spex API
  },
  "message": "Order placed successfully via Cash on Delivery and synced with Spex."
}
```

**Frontend Action Required:**
1. Clear the local cart state.
2. Route the user directly to an "Order Success / Thank You" screen.
3. No further API calls are needed from the frontend.

### Scenario B: Card Payment (`paymentMethod: "CARD"`)

For Card payments, the order is created in the database with a `PENDING` payment status. The backend integrates with **MPGS (Mastercard Payment Gateway Services)** to generate a secure checkout session. The shipping dispatch to Spex is deferred until the payment is actually verified.

**Backend Response for CARD:**
```json
{
  "order": {
    "id": "ord-12345",
    "totalAmount": "150.00",
    "currentStatus": "PLACED",
    "paymentStatus": "PENDING"
  },
  "paymentSession": {
    "sessionId": "SESSION000213123123123",
    "successIndicator": "0123456789ABCDEF",
    "version": "60"
  }
}
```

**Frontend Action Required:**
1. **Do NOT** show the "Order Success" screen yet.
2. Extract the `sessionId` from `paymentSession.sessionId`.
3. Use the `sessionId` to initialize the MPGS hosted checkout SDK (either via the Web Hosted Session or the MPGS Flutter SDK). 
4. The user will enter their card details into the secure MPGS widget.
5. Once the SDK returns a successful interaction callback, verify the callback using the `successIndicator` provided in the backend response.
6. **Important:** Call the backend verification endpoint (e.g., `POST /api/payments/verify`) passing the `orderId` so the backend can verify the payment with the bank, mark the order as `PAID`, and automatically trigger the Spex shipping dispatch.

---

## 3. Order Status & Shipping Tracking

You do not need to poll the backend constantly for shipping updates.

- **Automated Tracking:** The backend runs a cron job every hour that syncs with the Spex API. 
- **Status Updates:** If a Spex driver delivers the package, the backend automatically updates the order status to `DELIVERED`.
- **Push Notifications:** The backend automatically fires Push Notifications to the user's device when the order status changes (e.g., "Order Shipped! 🚚", "Order Delivered ✅"). 
- **Flutter Devs:** Ensure your app is configured to receive and handle these push notifications (e.g., routing the user to the `/profileUser/orders` screen when tapped).

## 4. Error Handling 

The backend now uses specific Error Classes for validation. Ensure you catch `400` and `409` status codes.
- If you receive an `InsufficientStockError`, the backend will include the `productId`. Highlight that product in the cart UI as out of stock.
- If you receive an `InvalidCouponError`, show the error message in the checkout UI so the user can remove or change the coupon.
