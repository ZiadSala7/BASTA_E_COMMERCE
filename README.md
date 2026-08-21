# 🏗️ Marketplace Backend API Documentation

This repository houses the backend codebase for the Pasta E-Commerce Marketplace. Built on a modern and robust Node.js stack, it implements modular architecture, role-based access control, file uploading, background job scheduling, and high-performance transactional logic.

---

## 🚀 Tech Stack & Core Libraries

- **Language & Runtime:** TypeScript, Node.js
- **Framework:** Express.js (v5)
- **Database ORM:** Drizzle ORM
- **Database Engine:** PostgreSQL (utilizing `pg` and `postgres` clients)
- **Validation:** Zod schemas
- **Authentication:** JWT Bearer Token (`Authorization: Bearer <token>`)
- **File Uploads:** Multer (handling images, legal PDFs, and Excel bulk sheets)
- **Background Jobs:** Node-Cron

---

## 🗂️ Project Structure

The project is structured following the **Controller-Service-Repository/Model** pattern to keep concerns separated, maintainable, and testable.

```text
src/
├── db/              ← Drizzle connection, schema definitions, and migrations
│   ├── schema/      ← Separate schema definitions per model
│   └── seed.ts      ← Database seeding script
├── middleware/      ← Auth guard, role check, uploads configuration, error validation
├── modules/         ← Feature folders (each folder encapsulates a module)
│   └── [module]/
│       ├── [module].routes.ts      ← Presentation: API Endpoint routes
│       ├── [module].controller.ts  ← Presentation: Handles Request/Response
│       ├── [module].validation.ts  ← Validation: Zod schemas for body/query parsing
│       └── [module].service.ts     ← Business Logic: Core app rules & database queries
├── types/           ← Custom Type definitions (e.g., extending Express Request)
├── utils/           ← Helper utilities (e.g., mailer)
└── server.ts        ← Express application setup & registration of routes
```

---

## ⚙️ Getting Started & Setup

### 1. Prerequisites
Ensure you have the following installed on your machine:
- Node.js (v18+)
- PostgreSQL Database

### 2. Environment Variables Configuration
Create a `.env` file in the root directory. Use the following template:

```env
PORT=3000
DATABASE_URL=postgresql://<username>:<password>@localhost:5432/<database_name>
JWT_SECRET=your_super_secret_jwt_key
EMAIL_USER=your_gmail_address@gmail.com
EMAIL_PASS=your_gmail_app_password
```

> [!NOTE]
> The mail utility uses Gmail services. For security reasons, do not use your primary password; instead, generate and supply a Google **App Password**.

### 3. Installation
Install the project dependencies using npm:
```bash
npm install
```

### 4. Database Setup & Migrations
We use Drizzle Kit to manage migrations. Run the following commands:

* **Generate Migrations:**
  ```bash
  npx drizzle-kit generate
  ```

* **Push Schema changes to DB:**
  ```bash
  npx drizzle-kit push
  ```

### 5. Seeding the Database
To populate the database with initial categories, vendor stores, and products, run the incremental seeding script:
```bash
npm run seed
```
This runs the seeding code in [seed.ts](file:///Users/barakat/Desktop/Pasta-e-Commerce/backend/src/db/seed.ts), which populates the database and connects objects to default testing accounts.

### 6. Starting the Server
Run the Express server in development mode with hot reloading:
```bash
npm run dev
```
The server will boot up and listen on `http://localhost:3000` (or your defined `PORT`).

---

## 🔐 Authentication & Role-Based Access Control

The API utilizes JSON Web Tokens (JWT) for secure authorization. To hit restricted endpoints:
1. Provide the JWT in the HTTP request headers:
   `Authorization: Bearer <your_jwt_token>`
2. Roles supported: `CUSTOMER` · `VENDOR` · `ADMIN`

---

## 📌 API Reference

### 1. Users Module

Prefix: `/api/users`  
Tracks authentication, credentials, profile information, and user account status.

#### `POST /api/users/register`
Registers a new account. Sends an verification email to the user.
- **Auth Required:** No
- **Body:**
  - `name` (string, min 2)
  - `email` (valid email string)
  - `password` (string, min 6)
  - `phone?` (string, optional)
  - `role?` (`ADMIN` | `VENDOR` | `CUSTOMER`, default `CUSTOMER`)
  - `referralCode?` (string, optional 8-char code from inviting friend)
- **Notes:** Newly created accounts start in a `PENDING` state until email is confirmed. If a valid `referralCode` is provided, reward coupons are issued to both the referrer and the new user.

> [!TIP]
> **Flutter Developers:** See the complete referral integration guide with copy-paste UI in [`FLUTTER_REFERRAL_GUIDE.md`](./FLUTTER_REFERRAL_GUIDE.md).

#### `POST /api/users/login`
Authenticates a user and generates a 7-day JWT.
- **Auth Required:** No
- **Body:** `email` (string), `password` (string)
- **Returns:** User object details + JWT token.
- **Notes:** Blocks login attempts for accounts in `PENDING` or `INACTIVE` status.

#### `GET /api/users/me`
Retrieves profile info (ID and role) of the authenticated user.
- **Auth Required:** Yes (Any role)
- **Returns:** `{ status: 'success', data: { id, role } }`

#### `GET /api/users/`
Returns a paginated, filterable list of all registered users.
- **Auth Required:** Yes (`ADMIN` only)
- **Query Params:**
  - `page?` (number, defaults to 1)
  - `limit?` (number, defaults to 10)
  - `search?` (string, searches emails)
  - `role?` (`ADMIN` | `VENDOR` | `CUSTOMER`)
  - `status?` (`ACTIVE` | `INACTIVE` | `PENDING`)

#### `POST /api/users/forgot-password`
Sends a password reset token to the specified email address.
- **Auth Required:** No
- **Body:** `email` (string)
- **Notes:** Always returns success to prevent email enumeration. Token is valid for 1 hour.

#### `POST /api/users/reset-password`
Overwrites the password using the reset token.
- **Auth Required:** No
- **Body:** `token` (string), `newPassword` (string, min 8)
- **Notes:** Upon successful reset, the token is permanently consumed and deleted.

#### `POST /api/users/confirm-email`
Activates a `PENDING` account using the confirmation token received via email.
- **Auth Required:** No
- **Body:** `token` (string)

#### `POST /api/users/resend-confirmation`
Resends the activation token to the user's email address.
- **Auth Required:** No
- **Body:** `email` (string)

#### `POST /api/users/change-password`
Modifies the password for the current logged-in user.
- **Auth Required:** Yes (Any role)
- **Body:** `oldPassword` (string), `newPassword` (string, min 8)

#### `PATCH /api/users/profile`
Updates profile info for the logged-in user.
- **Auth Required:** Yes (Any role)
- **Body:** `name?` (string, min 2), `phone?` (string), `email?` (string)
- **Notes:** If the email is altered, the status is set back to `PENDING`, and a new verification email is sent.

#### `PATCH /api/users/admin/:id`
Allows an administrator to modify details of a specific user.
- **Auth Required:** Yes (`ADMIN` only)
- **Params:** `id` (UUID of the target user)
- **Body:** `name?` (string), `phone?` (string), `email?` (string), `role?` (`ADMIN` | `VENDOR` | `CUSTOMER`)

#### `PATCH /api/users/:id/status`
Allows an admin to activate or suspend a user account.
- **Auth Required:** Yes (`ADMIN` only)
- **Params:** `id` (UUID of the target user)
- **Body:** `status` (`ACTIVE` | `INACTIVE`)

#### `PATCH /api/users/fcm-token`
Registers or updates the user's Firebase Cloud Messaging (FCM) device token for push notifications.
- **Auth Required:** Yes (Any role)
- **Body:** `token` (string, required)

#### `POST /api/users/social-login`
Authenticates via Firebase ID Token and optionally registers FCM device token.
- **Auth Required:** No
- **Body:** `idToken` (string), `role?` (`VENDOR` | `CUSTOMER`), `fcmToken?` (string)

---

### 2. Categories Module

Prefix: `/api/categories`  
Manages product categorization for the marketplace.

#### `GET /api/categories`
Retrieves a list of all categories.
- **Auth Required:** No

#### `POST /api/categories`
Creates a new product category.
- **Auth Required:** Yes (`ADMIN` only)
- **Body:**
  - `name` (string, min 2)
  - `slug` (unique, lowercase letters, numbers, and hyphens)
  - `description?` (string, optional)

#### `PATCH /api/categories/:id`
Updates category parameters.
- **Auth Required:** Yes (`ADMIN` only)
- **Params:** `id` (UUID of the category)
- **Body:** `name?` (string), `slug?` (string), `description?` (string)

#### `DELETE /api/categories/:id`
Deletes a category.
- **Auth Required:** Yes (`ADMIN` only)
- **Params:** `id` (UUID)
- **Notes:** The database maintains structural integrity via restrictive foreign keys. The deletion fails if products are currently mapped to this category.

---

### 3. Stores Module

Prefix: `/api/stores`  
Manages vendor store creation, profile updating, and status cycles.

#### `POST /api/stores`
Registers a store under the vendor's account. 
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Body (Multipart Form Data):**
  - `name` (string, min 3)
  - `slug` (unique, lowercase alphanumeric and hyphens)
  - `description?` (string, optional)
  - `contactEmail?` (valid email, optional)
  - `contactPhone?` (string, optional)
- **Files:** `commercialRegister` (PDF or image, required if requesting role is `VENDOR`)
- **Side Effects:** Stores created by VENDORS default to `PENDING` status. The system triggers notifications to VENDORS (acknowledging review status) and to ADMINS (prompting for store approval review). Stores created by ADMINS are auto-approved.

#### `GET /api/stores`
Retrieves approved stores.
- **Auth Required:** No
- **Query Params:** `page?` (number), `limit?` (number)

#### `GET /api/stores/admin`
Retrieves stores filtering by their review status.
- **Auth Required:** Yes (`ADMIN` only)
- **Query Params:** `page?` (number), `limit?` (number), `status?` (`PENDING` | `APPROVED` | `REJECTED`)

#### `GET /api/stores/me`
Retrieves all stores registered under the authenticated vendor's ID.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)

#### `GET /api/stores/:slug`
Fetches a single approved store details using its slug.
- **Auth Required:** No (Public)

#### `PATCH /api/stores/:id/status`
Approves or rejects a store application.
- **Auth Required:** Yes (`ADMIN` only)
- **Params:** `id` (UUID)
- **Body:** `status` (`APPROVED` | `REJECTED`), `rejectionReason?` (string)
- **Side Effects:** Triggers a system notification to the vendor informing them of the approval result.

#### `PATCH /api/stores/:id`
Updates details of a store.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Params:** `id` (UUID of the store)
- **Body (Multipart Form Data):** `name?` (string), `description?` (string), `contactEmail?` (string), `contactPhone?` (string)
- **Files:** `commercialRegister?` (PDF/Image, optional update)
- **Notes:** Ownership is enforced; VENDORS can only edit stores they own.

---

### 4. Subscriptions Module

Prefix: `/api/subscriptions`  
Configures packages and monitors store subscription states.

#### `GET /api/subscriptions/packages`
Retrieves active subscription packages.
- **Auth Required:** No
- **Query Params:** `page?` (number), `limit?` (number)

#### `POST /api/subscriptions/packages`
Defines a subscription package for vendors.
- **Auth Required:** Yes (`ADMIN` only)
- **Body:**
  - `name` (string)
  - `price` (number, must be >= 0)
  - `productLimit` (integer, must be > 0)
  - `features?` (string, optional)

#### `PATCH /api/subscriptions/packages/:id`
Edits configurations of a subscription package.
- **Auth Required:** Yes (`ADMIN` only)
- **Params:** `id` (UUID)
- **Body:** `name?` (string), `price?` (number), `productLimit?` (integer), `features?` (string)

#### `DELETE /api/subscriptions/packages/:id`
Deletes a subscription package.
- **Auth Required:** Yes (`ADMIN` only)
- **Params:** `id` (UUID)

#### `GET /api/subscriptions/admin/pending`
Retrieves subscription purchase requests awaiting admin review.
- **Auth Required:** Yes (`ADMIN` only)

#### `PATCH /api/subscriptions/admin/:id/status`
Approves or rejects a vendor's subscription request.
- **Auth Required:** Yes (`ADMIN` only)
- **Params:** `id` (UUID of the subscription record)
- **Body:** `status` (`ACTIVE` | `REJECTED`), `rejectionReason?` (string)
- **Side Effects:** Triggers notifications to vendors. If approved, vendor gains active subscription status.

#### `GET /api/subscriptions/me`
Retrieves active subscription details.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Query Params:** `storeId` (UUID, required)

#### `POST /api/subscriptions/subscribe`
Sends a purchase request for a subscription package.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Body:** `packageId` (UUID), `storeId` (UUID)
- **Notes:** Subscriptions start as `PENDING` and must be approved by an Admin. Only one active/pending subscription request is allowed per store.

---

### 5. Products Module

Prefix: `/api/products`  
Manages product listings, images, and verified purchase reviews.

#### `POST /api/products`
Inserts a new product listing.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Body:**
  - `categoryId` (UUID)
  - `name` (string, min 2)
  - `slug` (unique, lowercase alphanumeric and hyphens)
  - `description?` (string, optional)
  - `price` (positive number)
  - `compareAtPrice?` (positive number, optional discount comparison)
  - `discountEndDate?` (ISO datetime string, optional)
  - `stockQuantity?` (integer >= 0, default 0)
  - `sku?` (string, optional)
  - `storeId?` (UUID, optional for admins, default links to vendor's store)
- **Notes:** Requires the vendor store to have an active approved subscription and prevents creation if the package's listing limit has been reached.

#### `GET /api/products`
Lists all public active products, including main image URLs.
- **Auth Required:** No
- **Query Params:**
  - `page?`, `limit?`
  - `search?` (fuzzy match on name)
  - `category?` (filter by category slug)
  - `store?` (filter by store slug)

#### `GET /api/products/vendor/me`
Retrieves products created by the authenticated vendor.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Query Params:** `page?`, `limit?`, `search?`

#### `GET /api/products/:slug`
Retrieves details of a single product using its slug.
- **Auth Required:** No

#### `PATCH /api/products/:id`
Updates product specifications.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Params:** `id` (UUID)
- **Body:** `categoryId?`, `name?`, `description?`, `price?`, `compareAtPrice?`, `discountEndDate?`, `stockQuantity?`, `sku?`, `isActive?` (boolean)
- **Notes:** Ownership check is enforced at the controller level.

#### `DELETE /api/products/:id`
Hides a product listing.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Params:** `id` (UUID)
- **Notes:** Soft delete implementation: sets `isActive = false` to safeguard past invoice structures and database records.

#### `POST /api/products/:id/images`
Uploads a product display image.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Params:** `id` (UUID of the product)
- **Body (Multipart Form Data):** `orderIndex?` (integer index, defaults to 0)
- **Files:** `image` (Required image file, size limit: 5MB)

#### `DELETE /api/products/:id/images/:imageId`
Deletes a product display image.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Params:** `id` (UUID of product), `imageId` (UUID of image record)

#### `POST /api/products/:id/reviews`
Submits a rating and text review.
- **Auth Required:** Yes (Any role)
- **Params:** `id` (UUID of product)
- **Body:** `rating` (integer 1–5), `comment?` (string)
- **Notes:** **Verified Purchase Enforcement:** Checks the orders table to verify that the requesting user has purchased the item and that the order status is marked as `DELIVERED`. Triggers a notification to the vendor.

#### `GET /api/products/:id/reviews`
Retrieves reviews left on a product.
- **Auth Required:** No

#### `DELETE /api/products/reviews/:reviewId`
Deletes a review.
- **Auth Required:** Yes (Any role)
- **Params:** `reviewId` (UUID)
- **Notes:** Can only be executed by the author of the review or an `ADMIN`.

#### `POST /api/products/bulk-upload`
Allows uploading product listings in bulk via Excel files.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Files:** `file` (Excel .xlsx / .xls or CSV, size limit: 10MB)
- **Returns:** JSON object containing count of successful and failed rows, along with detailed parsing logs.

---

### 6. Cart Module

Prefix: `/api/carts`  
Manages items in the user's shopping cart and previews coupon discounts.

#### `POST /api/carts/items`
Adds a product to the cart or increments its count.
- **Auth Required:** Yes (Any role)
- **Body:** `productId` (UUID), `quantity` (positive integer, default 1)
- **Notes:** Creates a cart if none exists. Validates current stock level before insertion.

#### `GET /api/carts`
Retrieves the logged-in user's cart containing itemized products, subtotal, and merged images.
- **Auth Required:** Yes (Any role)

#### `PATCH /api/carts/items/:productId`
Updates the quantity of a cart item.
- **Auth Required:** Yes (Any role)
- **Params:** `productId` (UUID)
- **Body:** `quantity` (integer >= 1)
- **Notes:** Rejects requests exceeding actual product stock levels.

#### `DELETE /api/carts/items/:productId`
Removes an item from the cart.
- **Auth Required:** Yes (Any role)
- **Params:** `productId` (UUID)

#### `POST /api/carts/apply-coupon`
Simulates checkout pricing and applies a coupon discount.
- **Auth Required:** Yes (Any role)
- **Body:** `code` (string)
- **Returns:** `{ cartTotal, discountAmount, finalTotal, appliedCoupon }`
- **Notes:** Validates date ranges, limits, minimum amounts, and eligibility. Does not consume usage limits (usage is only incremented during checkout).

---

### 7. Orders Module

Prefix: `/api/orders`  
Controls placing orders, order status tracking, and fulfillment operations.

#### `POST /api/orders/checkout`
Converts items in the active cart into a confirmed order.
- **Auth Required:** Yes (Any role)
- **Body:**
  - `streetAddress` (string)
  - `city` (string)
  - `state` (string)
  - `postalCode` (string)
  - `country` (string)
  - `shippingRateId` (UUID)
  - `couponCode?` (string, optional)
- **Database Transaction Steps:**
  1. Ensures the cart is populated.
  2. Resolves shipping rate and checks coverage.
  3. Verifies stock availability for each item.
  4. Applies coupon (if provided) and calculates total discount.
  5. Inserts order and shipping records.
  6. Atomic stock decrement (`stockQuantity = stockQuantity - quantity`).
  7. Clears user cart.
- **Side Effects:** Sends notification triggers to each vendor involved in the purchase.

#### `GET /api/orders/me`
Retrieves orders placed by the authenticated customer.
- **Auth Required:** Yes (Any role)

#### `GET /api/orders/vendor`
Retrieves order items associated with the vendor's store.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)

#### `GET /api/orders/:id`
Retrieves detailed information of an order.
- **Auth Required:** Yes (Any role)
- **Params:** `id` (UUID)
- **Notes:** Ownership checks: customers can view only their own orders; vendors can view only orders containing products from their store.

#### `PATCH /api/orders/:id/status`
Updates order status and attaches details.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Params:** `id` (UUID)
- **Body:** `status` (`PROCESSING` | `SHIPPED` | `DELIVERED` | `CANCELLED`), `notes?` (string), `trackingNumber?` (string, optional - applied when status becomes `SHIPPED`)
- **Side Effects:** Stores state tracking records in the status history database and triggers a notification to the customer.

---

### 8. Coupons Module

Prefix: `/api/coupons`  
Manages promotional coupons for both platform-wide and store-specific discounts.

#### `GET /api/coupons`
Lists all coupons in the system.
- **Auth Required:** Yes (`ADMIN` only)
- **Query Params:** `page?`, `limit?`

#### `GET /api/coupons/vendor/me`
Lists coupons created by the logged-in vendor.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Query Params:** `page?`, `limit?`

#### `POST /api/coupons/admin`
Creates a platform-wide coupon applicable to all products.
- **Auth Required:** Yes (`ADMIN` only)
- **Body:**
  - `code` (string, min 3, auto-uppercased)
  - `type` (`FIXED` | `PERCENTAGE`)
  - `value` (positive number)
  - `minOrderAmount?` (number, default 0)
  - `maxDiscountAmount?` (number)
  - `usageLimit?` (integer)
  - `startDate?` (ISO datetime)
  - `endDate` (ISO datetime)

#### `POST /api/coupons/vendor`
Creates a store-restricted coupon applicable only to items sold by the creator store.
- **Auth Required:** Yes (`VENDOR` or `ADMIN`)
- **Body:** (Same as admin coupon body parameters above)
- **Notes:** Store ID is fetched automatically from the vendor's credentials.

#### `PATCH /api/coupons/:id/status`
Enables or disables a coupon code.
- **Auth Required:** Yes (`ADMIN` or `VENDOR`)
- **Params:** `id` (UUID)
- **Notes:** Security role guard: vendors can only toggle coupons linked to their own store.

---

### 9. Shipping Module

Prefix: `/api/shipping`  
Sets up the logistics infrastructure, zones, and shipping fees.

#### `POST /api/shipping/companies`
Registers a shipping provider.
- **Auth Required:** Yes (`ADMIN` only)
- **Body:** `name` (string, min 2), `logoUrl?` (URL string), `trackingUrlPrefix?` (URL string)

#### `GET /api/shipping/companies`
Lists all shipping providers.
- **Auth Required:** Yes (`ADMIN` only)

#### `POST /api/shipping/zones`
Registers a shipping zone covering multiple cities.
- **Auth Required:** Yes (`ADMIN` only)
- **Body:** `name` (string, min 2), `coveredCities` (array of strings, min 1)

#### `GET /api/shipping/zones`
Lists all geographic shipping zones.
- **Auth Required:** Yes (`ADMIN` only)

#### `POST /api/shipping/rates`
Registers shipping rates linking companies to zones.
- **Auth Required:** Yes (`ADMIN` only)
- **Body:** `companyId` (UUID), `zoneId` (UUID), `baseFee` (number >= 0), `estimatedDays` (string, e.g., "3-5 days")

#### `GET /api/shipping/rates`
Lists all registered shipping rates.
- **Auth Required:** Yes (`ADMIN` only)

#### `POST /api/shipping/calculate`
Calculates options and fees for a target delivery city.
- **Auth Required:** Yes (Any role)
- **Body:** `city` (string)
- **Returns:** Zone name matched, number of distinct vendors, and list of shipping methods with custom costs.
- **Notes:** The shipping fee calculation is: `baseFee * (number of unique vendor stores represented in the cart)`.

---

### 10. Favorites Module

Prefix: `/api/favorites`  
Manages user wishlist items.

#### `GET /api/favorites`
Lists all items saved in the user's wishlist.
- **Auth Required:** Yes (Any role)

#### `POST /api/favorites/toggle`
Toggles a product on/off the wishlist.
- **Auth Required:** Yes (Any role)
- **Body:** `productId` (UUID)
- **Returns:** `{ status: 'success', data: { action: 'added' | 'removed' } }`

---

### 11. Notifications Module

Prefix: `/api/notifications`  
In-app communication framework.

#### `GET /api/notifications`
Retrieves in-app notifications, ordered newest first.
- **Auth Required:** Yes (Any role)
- **Query Params:** `page?` (default 1), `limit?` (default 10, max 50)

#### `GET /api/notifications/unread-count`
Retrieves the total count of unread notifications.
- **Auth Required:** Yes (Any role)
- **Returns:** `{ status: 'success', data: { unreadCount: number } }`

#### `PATCH /api/notifications/:id/read`
Marks a specific notification as read.
- **Auth Required:** Yes (Any role)
- **Params:** `id` (UUID)

#### `POST /api/notifications/admin/send`
Allows admins to broadcast notifications to groups or individuals.
- **Auth Required:** Yes (`ADMIN` only)
- **Body:**
  - `title` (string, min 3)
  - `message` (string, min 5)
  - `link?` (string, optional)
  - `targetAudience` (`CUSTOMER` | `VENDOR` | `ALL`)
- **Side Effects:** Automatically sends Firebase Cloud Messaging (FCM) push notifications to all targeted active mobile devices.

> [!TIP]
> **Flutter Developers:** See the complete integration guide in [`FLUTTER_NOTIFICATION_GUIDE.md`](./FLUTTER_NOTIFICATION_GUIDE.md) for ready-to-use Dart service classes, background handlers, and routing.

---

## ⏰ Scheduled Background Jobs

The backend utilizes `node-cron` to execute a daily cron job scheduled at **Midnight (Africa/Cairo timezone)**:
1. **Warning Check:** Scans active subscriptions expiring in exactly 3 days and sends alert notifications to the vendors.
2. **Expiration Enforcement:** Scans active subscriptions where `expiresAt` is past current date/time. The job performs the following in a transaction:
   - Sets the subscription status to `EXPIRED`.
   - Modifies products associated with the expired store to set `isActive = false`.
   - dispatches notification warnings to the affected vendors.

For source details, see [subscriptions.cron.ts](file:///Users/barakat/Desktop/Pasta-e-Commerce/backend/src/modules/subscriptions/subscriptions.cron.ts).
