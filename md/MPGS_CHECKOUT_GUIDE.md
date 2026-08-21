# Mastercard (MPGS) Hosted Checkout Integration Guide

This guide explains the end-to-end integration of the Mastercard Hosted Checkout (MPGS) flow between the frontend and the backend.

## The Complete Flow

1. **Frontend** calls `POST /api/orders/checkout`.
2. **Backend** saves the order to the database, requests a generic session from MPGS, and returns `sessionId` + `order.id` to the frontend.
3. **Frontend** loads the Mastercard Javascript SDK and configures the `Checkout` object using the returned `sessionId` and `order.id`.
4. **Frontend** calls `Checkout.showLightbox()` to pop up the card entry modal.
5. The customer enters their credit card details and Mastercard processes the payment.
6. **Frontend's** `completeCallback` fires automatically on success.
7. **Frontend** must then call `GET /api/payments/verify/:orderId` to tell the backend to verify the transaction.
8. **Backend** securely verifies the transaction status directly with Mastercard, updates the database to `PAID`, dispatches shipping, and notifies the vendor.

---

## Step-by-Step Implementation

### Step 1: Include the Mastercard SDK Script

In your frontend application (e.g., in the `index.html` or dynamically injected into the checkout page), you need to include the Mastercard Hosted Checkout script. 

> [!NOTE]
> Replace `test-network.mtf.gateway.mastercard.com` with the production URL when going live.

```html
<script 
  src="https://test-network.mtf.gateway.mastercard.com/static/checkout/checkout.min.js" 
  data-error="errorCallback" 
  data-cancel="cancelCallback">
</script>
```

### Step 2: Call the Backend Checkout API

When the user clicks "Place Order", the frontend first needs to call the backend to generate the order and the payment session.

```javascript
// Example using fetch (run this when user submits the checkout form)
const response = await fetch('/api/orders/checkout', {
    method: 'POST',
    headers: { 
        'Content-Type': 'application/json', 
        'Authorization': `Bearer ${userToken}` 
    },
    body: JSON.stringify({
        streetAddress: "123 Pasta Lane",
        city: "Amman",
        state: "Amman",
        postalCode: "11118",
        country: "Jordan",
        paymentMethod: "CARD"
    })
});

const data = await response.json();

// Extract the required IDs for Mastercard
const orderId = data.data.order.id;
const totalAmount = data.data.order.totalAmount;
const sessionId = data.data.paymentSession.sessionId;

// Proceed to Step 3 with these values
initializeMastercardPayment(sessionId, orderId, totalAmount);
```

### Step 3: Configure the Mastercard Checkout Object

Once you have the `sessionId` and `orderId` from the backend, configure the global `Checkout` object provided by the script from Step 1.

> [!CAUTION]
> The `order.id` passed to the `Checkout.configure` method MUST be the UUID returned from the backend. Do not pass the `sessionId` here.

```javascript
// This function initializes the Mastercard modal
function initializeMastercardPayment(sessionId, orderId, totalAmount) {
    Checkout.configure({
        session: { 
            id: sessionId 
        },
        order: {
            amount: totalAmount,
            currency: 'JOD',
            description: 'Pasta E-Commerce Order',
            id: orderId // CRITICAL: This ties the MPGS transaction to your backend DB Order UUID!
        },
        interaction: {
            merchant: {
                name: 'Pasta E-Commerce',
                address: {
                    line1: 'Amman, Jordan'
                }
            },
            displayControl: {
                billingAddress: 'HIDE', // Hide if you already collected it on your checkout form
                shipping: 'HIDE'
            }
        }
    });
    
    // Open the payment modal (lightbox)
    Checkout.showLightbox();
}
```

### Step 4: Handle the Callbacks & Verify Payment

Mastercard requires you to define global callback functions that trigger when the user finishes, cancels, or fails the payment process. 

> [!IMPORTANT]
> When the payment succeeds on the frontend (`completeCallback`), you **must** call the backend's `verify` endpoint to finalize the order. Without this step, the backend will still consider the order as `PENDING` and vendors will not receive notifications.

```javascript
// 1. Success Callback
window.completeCallback = async function(response) {
    console.log("Mastercard Payment Complete", response);
    
    // Now that Mastercard processed the card, tell our backend to verify and fulfill the order!
    try {
        // Use the orderId we saved from Step 2
        const verifyResponse = await fetch(`/api/payments/verify/${orderId}`, {
            method: 'GET',
            headers: { 'Authorization': `Bearer ${userToken}` }
        });
        
        const verifyData = await verifyResponse.json();
        
        if (verifyData.status === 'success') {
            // Success! The order is now PAID in the backend. 
            // Redirect user to the Success Page.
            window.location.href = `/checkout/success?orderId=${orderId}`;
        } else {
            // Verification failed (e.g., fraudulent card or backend error)
            alert("Payment verification failed on our servers.");
        }
    } catch (error) {
        console.error("Backend verification error:", error);
    }
};

// 2. Error Callback
window.errorCallback = function(error) {
    console.error("Mastercard Payment Error", error);
    alert("There was an issue processing your card. Please try again.");
};

// 3. Cancel Callback
window.cancelCallback = function() {
    console.log("User closed the payment modal.");
    // Optionally redirect back to the cart or show a friendly message
};
```
