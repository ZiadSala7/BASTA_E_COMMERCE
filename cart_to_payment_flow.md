# Cart → Checkout Flow — Pasta E-Commerce API

> **Base URL:** `http://localhost:3000/api`  
> **Auth:** Bearer token (from login) passed in `Authorization` header  
> **Roles used in this flow:** `CUSTOMER`

---

## Overview

```
Add Items to Cart → View Cart → Apply Coupon (optional) → Calculate Shipping → Checkout
```

---

## Step 1 — Add Items to Cart

**Endpoint:** `POST /carts/items`  
**Auth:** Required (customer token)

### Request Body
```json
{
  "productId": "<PRODUCT_ID>",
  "quantity": 1
}
```

### Notes
- Call this once per product the user adds.
- If the same `productId` is added again, update quantity instead using Step 3.
- The backend validates stock availability automatically.

---

## Step 2 — View Cart

**Endpoint:** `GET /carts`  
**Auth:** Required (customer token)

### Response includes
- All cart items with current prices
- Active sale prices (if product has a valid `discountEndDate` that hasn't expired)
- Line totals per item
- Cart subtotal

### Important — Discount Logic
The backend applies a **discount waterfall**:
1. If a product has a `compareAtPrice` and its `discountEndDate` is in the future → sale price is applied automatically.
2. If the sale is expired → full `price` is used.
3. Coupon discount (Step 4) is applied on top of the already-discounted subtotal.

---

## Step 3 — Update Cart Item Quantity (optional)

**Endpoint:** `PATCH /carts/items/:productId`  
**Auth:** Required (customer token)

### Request Body
```json
{
  "quantity": 3
}
```

---

## Step 4 — Remove Item from Cart (optional)

**Endpoint:** `DELETE /carts/items/:productId`  
**Auth:** Required (customer token)

No body required. Pass the `productId` as a URL param.

---

## Step 5 — Apply Coupon (optional)

**Endpoint:** `POST /carts/apply-coupon`  
**Auth:** Required (customer token)

### Request Body
```json
{
  "code": "TECH10"
}
```

### Notes
- Coupon types: `PERCENTAGE` or `FIXED`
- `minOrderAmount` must be met for the coupon to be valid.
- `maxDiscountAmount` caps the discount for percentage coupons.
- The applied coupon code must be **passed again** at checkout (Step 7).
- If the user changes the cart after applying a coupon, re-validate by calling this again.

---

## Step 6 — Calculate Shipping

**Endpoint:** `POST /shipping/calculate`  
**Auth:** Required (customer token)

### Request Body
```json
{
  "city": "Amman"
}
```

### Response includes
- One or more `shippingRate` objects, each with an `id` and a cost.
- The user picks a shipping option.
- Store the selected `shippingRateId` — it is required for checkout.

---

## Step 7 — Checkout (Place Order)

**Endpoint:** `POST /orders/checkout`  
**Auth:** Required (customer token)

### Request Body
```json
{
  "streetAddress": "123 Pasta Lane",
  "city": "Amman",
  "state": "Amman",
  "postalCode": "11118",
  "country": "Jordan",
  "shippingRateId": "<SHIPPING_RATE_ID>",
  "couponCode": "TECH10"
}
```

> `couponCode` is optional — only include it if the user applied one in Step 5.

### Response includes
- Created order with a unique order `id`
- Final breakdown: subtotal, shipping cost, coupon discount, total
- Order status starts as `PENDING`

### Notes
- The cart is cleared automatically after a successful checkout.
- If payment is handled externally (e.g. cash on delivery or a payment gateway redirect), implement it before or after this call depending on your payment flow.

---

## Step 8 — View Order (Post-Checkout Confirmation)

**Endpoint:** `GET /orders/:orderId`  
**Auth:** Required (customer token)

Use the `id` from the checkout response to display the order confirmation screen.

---

## Step 9 — View All My Orders

**Endpoint:** `GET /orders/me`  
**Auth:** Required (customer token)

Lists all past orders for the logged-in customer. Use this for the order history screen.

---

## Full Flow Summary (Flutter implementation guide)

| Step | Screen | API Call |
|------|--------|----------|
| 1 | Product detail → "Add to Cart" button | `POST /carts/items` |
| 2 | Cart screen loads | `GET /carts` |
| 3 | User changes quantity | `PATCH /carts/items/:productId` |
| 4 | User removes item | `DELETE /carts/items/:productId` |
| 5 | User enters coupon code | `POST /carts/apply-coupon` |
| 6 | User enters delivery city | `POST /shipping/calculate` → display rate options |
| 7 | User taps "Place Order" | `POST /orders/checkout` |
| 8 | Order confirmation screen | `GET /orders/:orderId` |
| 9 | Orders history screen | `GET /orders/me` |

---

## Error Handling Tips

| Scenario | What to do in Flutter |
|----------|-----------------------|
| Stock insufficient | Show "Out of stock" on add-to-cart |
| Coupon invalid / expired | Show inline error below coupon field |
| City not covered by shipping | Show "Delivery not available in your area" |
| Checkout fails | Keep cart intact, show retry option |
| Token expired | Redirect to login, then deep-link back to cart |

---

## FCM Token (Push Notifications)

After login, register the device token so the user gets order status push notifications:

**Endpoint:** `PATCH /users/fcm-token`  
**Auth:** Required (customer token)

```json
{
  "token": "<FIREBASE_DEVICE_TOKEN>"
}
```

Call this once on app launch after the user is logged in and Firebase has issued a device token.
