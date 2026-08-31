# 📱 Flutter Developer Guide: Dynamic Coupon Referral System (Updated)

This document provides a comprehensive guide to implementing the **Dynamic Coupon Referral System** in the Flutter mobile application. It covers exactly what data needs to be sent, what the API returns, and the UI/UX flows.

---

## 🔗 System Overview & Business Logic

The referral reward logic is completely dynamic and controlled by the Admin Dashboard. The system behaves as follows:
1. **Registration (The Invitee)**: When a new user registers with a friend's referral code, they **immediately** receive a reward coupon.
2. **First Purchase (The Inviter)**: The user whose code was used **does not** receive their reward upon registration. Instead, they automatically receive their coupon (and a push notification) only after the new user's **first order** is marked as `DELIVERED`.

You don't need to handle the deferred logic; the backend handles it. You just need to ensure the referral code is sent during registration, and provide a UI for users to see their earned coupons.

---

## 🚀 1. User Registration (Sending the Referral Code)

When a new user signs up, if they have a referral code, you must send it in the registration payload.

**Endpoint:** `POST /api/users/register` (or your existing registration endpoint)

You should include the `refCode` field in the request body if the user entered one.
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "password": "securepassword123",
  "phone": "+962791234567",
  "role": "CUSTOMER",
  "refCode": "A1B2C3D4" // <-- IMPORTANT: Add this if the user provides it!
}
```

---

## 🎁 2. Fetching & Displaying the User's Coupons

Create a new screen or section in the User Profile called **"My Rewards & Coupons"**.

**Endpoint:** `GET /api/coupons/my-coupons`
**Headers:** `Authorization: Bearer <your-jwt-token>`
**Query Parameters (Optional):** `?page=1&limit=50`

### Example Response:
```json
{
  "status": "success",
  "totalItems": 1,
  "totalPages": 1,
  "currentPage": 1,
  "limit": 50,
  "data": [
    {
      "id": "e6a2b842-1234-4abcd-1234-abcdef123456",
      "code": "REF-ABCDEF",
      "storeId": null,
      "userId": "user-uuid",
      "type": "FIXED", // Enum: 'FIXED' or 'PERCENTAGE'
      "value": "5.00",
      "minOrderAmount": "0.00",
      "maxDiscountAmount": null,
      "usageLimit": 1, // Number of times it can be used
      "usedCount": 0, // Number of times it HAS been used
      "isActive": true,
      "startDate": "2026-08-31T12:00:00.000Z",
      "endDate": "2026-09-30T12:00:00.000Z",
      "createdAt": "2026-08-31T12:00:00.000Z"
    }
  ]
}
```

### Dart Model Recommendation (Flutter)
```dart
class Coupon {
  final String id;
  final String code;
  final String type; // 'FIXED' or 'PERCENTAGE'
  final String value;
  final int usageLimit;
  final int usedCount;
  final bool isActive;
  final DateTime endDate;

  // You can calculate if the coupon is valid in the UI:
  bool get isValid => isActive && usedCount < usageLimit && endDate.isAfter(DateTime.now());
}
```

---

## 🎨 3. UI/UX Implementation Checklist

Please implement the following in the Flutter app:

- [ ] **Referral Code Input**: During the Sign-Up flow, add an optional text field for "Referral Code". Send this as `refCode` to the backend.
- [ ] **Share Referral Code**: In the User Profile screen, display the logged-in user's `referralCode` (available in the `user` object). Provide a "Copy" and "Share" button so they can send it to friends.
- [ ] **"My Coupons" Screen**: Create a dedicated screen or a section in the Profile that calls `GET /api/coupons/my-coupons`.
- [ ] **Coupon Card UI**:
  - Show the `code` in a large, monospace font. Allow the user to tap it to copy it to their clipboard.
  - Show the reward amount clearly. Logic: `if (type == 'FIXED') { print('\$value JOD OFF'); } else { print('\$value% OFF'); }`
  - Show a status badge: 
    - 🟩 **Active**: If `isValid` is true.
    - 🟥 **Used/Expired**: If `isValid` is false.
- [ ] **Push Notification Handling (Firebase FCM)**: 
  - The backend sends a notification payload when a coupon is awarded.
  - The notification includes a deep link URL field: `/profileUser/coupons` or similar. Ensure the app catches this deep link and routes the user directly to their "My Coupons" screen.
