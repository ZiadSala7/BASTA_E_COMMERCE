class Endpoints {
  static const String users = 'api/users';
  static const String login = '$users/login';
  static const String register = '$users/register';
  static const String forgotPassword = '$users/forgot-password';
  static const String resetPassword = '$users/reset-password';
  static const String confirmEmail = '$users/confirm-email';
  static const String resendConfirmation = '$users/resend-confirmation';
  static const String changePassword = '$users/change-password';
  static const String profile = '$users/profile';
  static const String logout = '$users/logout';
  static const String categories = 'api/categories';
  static const String products = 'api/products';
  static String productReviews(String productId) =>
      '$products/$productId/reviews';
  static const String stores = 'api/stores';
  static const String favorites = 'api/favorites';
  static const String toggleFavorite = '$favorites/toggle';
  static const String cart = 'api/carts';
  static const String cartItems = 'api/carts/items';
  static String cartItem(String itemId) => '$cartItems/$itemId';
  static const String myOrders = 'api/orders/me';
  static const String userProfile = '$users/me';
}
