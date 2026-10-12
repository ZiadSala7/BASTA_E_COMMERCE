import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract class AppNavigation {
  const AppNavigation._();

  static void popOrGo(
    BuildContext context, {
    String fallbackLocation = '/mainNavigation',
  }) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackLocation);
    }
  }
}
