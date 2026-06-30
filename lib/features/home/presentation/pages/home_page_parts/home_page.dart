part of '../home_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const HomePage({super.key, this.onMenuPressed});

  @override
  State<HomePage> createState() => _HomePageState();
}
