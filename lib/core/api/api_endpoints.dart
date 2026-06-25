class Endpoints {
  static const String users = 'api/users';
  static const String login = '$users/login';
  static const String socialLogin = '$users/social-login';
  static const String register = '$users/register';
  static const String userProfile = '$users/me';
  static const String forgotPassword = '$users/forgot-password';
  static const String resetPassword = '$users/reset-password';
  static const String confirmEmail = '$users/confirm-email';
  static const String profile = '$users/profile';
  static const String updateFcmToken = '$users/fcm-token';

  static const String categories = 'api/categories';
  static const String stores = 'api/stores';
  static const String products = 'api/products';
  static const String favorites = 'api/favorites';
  static const String cart = 'api/carts';
  static const String cartItems = '$cart/items';
  static String cartItem(String productId) => '$cartItems/$productId';
  static const String applyCoupon = '$cart/apply-coupon';
  static const String calculateShipping = 'api/shipping/calculate';
  static const String checkout = 'api/orders/checkout';
  static const String myOrders = 'api/orders/me';
  static const String notifications = 'api/notifications';
  static const String unreadNotificationsCount = '$notifications/unread-count';
  static String markNotificationRead(String notificationId) =>
      '$notifications/$notificationId/read';
}
