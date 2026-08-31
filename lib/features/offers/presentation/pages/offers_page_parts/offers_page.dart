part of '../offers_page.dart';

class OffersPage extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final int initialTabIndex;

  const OffersPage({
    super.key,
    this.onMenuPressed,
    this.initialTabIndex = 0,
  });

  @override
  State<OffersPage> createState() => _OffersPageState();
}
