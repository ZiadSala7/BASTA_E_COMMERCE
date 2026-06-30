part of '../cart_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, this.onStartShopping, this.onBack});

  final VoidCallback? onStartShopping;
  final VoidCallback? onBack;

  @override
  State<CartPage> createState() => _CartPageState();
}
