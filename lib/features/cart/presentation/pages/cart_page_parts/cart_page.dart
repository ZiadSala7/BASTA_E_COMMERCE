part of '../cart_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, this.onStartShopping});

  final VoidCallback? onStartShopping;

  @override
  State<CartPage> createState() => _CartPageState();
}
