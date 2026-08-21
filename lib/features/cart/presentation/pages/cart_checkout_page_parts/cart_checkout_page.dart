part of '../cart_checkout_page.dart';

class CartCheckoutPage extends StatefulWidget {
  const CartCheckoutPage({super.key, this.couponCode});

  final String? couponCode;

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}
