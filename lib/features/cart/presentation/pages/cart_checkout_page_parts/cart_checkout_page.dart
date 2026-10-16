part of '../cart_checkout_page.dart';

class CartCheckoutPage extends StatefulWidget {
  const CartCheckoutPage({super.key, this.couponCode, this.couponDiscount = 0});

  final String? couponCode;
  final double couponDiscount;

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}
