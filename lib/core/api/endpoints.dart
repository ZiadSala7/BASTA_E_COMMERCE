class Endpoints {
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

  static const String categories = 'api/categories';

  static const String products = 'api/products';
  static String productReviews(String productId) =>
      '$products/$productId/reviews';

  static const String stores = 'api/stores';

  static const String favorites = 'api/favorites';
  static const String toggleFavorite = '$favorites/toggle';

  static const String cart = 'api/carts';
  static const String cartItems = '$cart/items';
  static String cartItem(String productId) => '$cartItems/$productId';
  static const String applyCoupon = '$cart/apply-coupon';

  static const String shipping = 'api/shipping';
  static const String calculateShipping = '$shipping/calculate';

  static const String orders = 'api/orders';
  static const String checkout = '$orders/checkout';
  static const String myOrders = '$orders/me';
  static String orderDetails(String orderId) => '$orders/$orderId';
  static String orderStatus(String orderId) => '$orders/$orderId/status';
  static const String vendorOrders = '$orders/vendor';

  static const String payments = 'api/payments';
  static String verifyPayment(String orderId) => '$payments/verify/$orderId';

  static const String notifications = 'api/notifications';
  static const String unreadNotificationsCount = '$notifications/unread-count';
  static String markNotificationRead(String notificationId) =>
      '$notifications/$notificationId/read';
}
