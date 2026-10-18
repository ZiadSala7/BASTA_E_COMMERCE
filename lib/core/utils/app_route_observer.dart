import 'package:flutter/widgets.dart';

class AppRouteObserver extends NavigatorObserver {
  AppRouteObserver({String initialRoute = '/'})
      : currentRoute = ValueNotifier<String>(initialRoute);

  final ValueNotifier<String> currentRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _extractRouteName(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _extractRouteName(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _extractRouteName(newRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (previousRoute != null) {
      _extractRouteName(previousRoute);
    }
  }

  void _extractRouteName(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      final path = Uri.tryParse(name)?.path ?? name;
      if (currentRoute.value != path) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          currentRoute.value = path;
        });
      }
    }
  }
}
