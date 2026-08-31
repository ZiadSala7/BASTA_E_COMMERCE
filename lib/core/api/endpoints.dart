class Endpoints {
  // Auth & Profile
  static const String users = 'api/users';
  static const String login = '$users/login';
  static const String socialLogin = '$users/social-login';
  static const String register = '$users/register';
  static const String userProfile = '$users/me';
  static const String forgotPassword = '$users/forgot-password';
  static const String resetPassword = '$users/reset-password';
  static const String confirmEmail = '$users/confirm-email';
  static const String resendConfirmation = '$users/resend-confirmation';
  static const String changePassword = '$users/change-password';
  static const String profile = '$users/profile';
  static const String logout = '$users/logout';
  static const String updateFcmToken = '$users/fcm-token';

  // Banners
  static const String banners = 'api/banners';

  // Categories & Catalog
  static const String categories = 'api/categories';
  static const String products = 'api/products';
  static String productDetails(String slugOrId) => '$products/$slugOrId';
  static String productReviews(String productId) =>
      '$products/$productId/reviews';
  static String reviewDetails(String reviewId) =>
      '$products/reviews/$reviewId';

  // Stores
  static const String stores = 'api/stores';
  static String storeDetails(String slug) => '$stores/$slug';

  // Wishlist & Favorites
  static const String favorites = 'api/favorites';
  static const String toggleFavorite = '$favorites/toggle';

  // Cart & Coupons
  static const String cart = 'api/carts';
  static const String cartItems = '$cart/items';
  static String cartItem(String variantId) => '$cartItems/$variantId';
  static const String applyCoupon = '$cart/apply-coupon';

  // User Coupons & Rewards
  static const String coupons = 'api/coupons';
  static const String myCoupons = '$coupons/my-coupons';

  // Shipping
  static const String shipping = 'api/shipping';
  static const String calculateShipping = '$shipping/calculate';

  // Orders & Tracking
  static const String orders = 'api/orders';
  static const String checkout = '$orders/checkout';
  static const String myOrders = '$orders/me';
  static String orderDetails(String orderId) => '$orders/$orderId';
  static String orderStatus(String orderId) => '$orders/$orderId/status';
  static String orderInvoice(String orderId) => '$orders/$orderId/invoice';
  static const String vendorOrders = '$orders/vendor';

  // Online Card Payments (MPGS)
  static const String payments = 'api/payments';
  static String verifyPayment(String orderId) => '$payments/verify/$orderId';
  static String cancelPayment(String orderId) => '$payments/cancel/$orderId';

  // Notifications
  static const String notifications = 'api/notifications';
  static const String unreadNotificationsCount = '$notifications/unread-count';
  static String markNotificationRead(String notificationId) =>
      '$notifications/$notificationId/read';
}
