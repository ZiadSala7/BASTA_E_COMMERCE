import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../di/service_locator.dart';
import '../utils/app_router.dart';

/// Routes the user to the correct screen after a notification tap.
///
/// Backend push payloads carry a `data` block with `path` and `type`:
/// ```json
/// {
///   "type": "ORDER",
///   "path": "/orders/e93240e4-54c3-42e1-a20d-83b3793798cf"
/// }
/// ```
class NotificationNavigator {
  NotificationNavigator._();

  static void handleNotificationTap(Map<String, dynamic> data) {
    final path = data['path']?.toString() ?? '';
    final type = data['type']?.toString().toUpperCase() ?? '';

    final route = _routeFor(path, type);
    debugPrint(
      'Navigating from notification -> Type: $type, Path: $path, Route: $route',
    );

    sl<GoRouter>().push(route);
  }

  static String _routeFor(String path, String type) {
    if (path.contains('/orders')) {
      return AppRoutes.orders;
    }

    if (path.contains('/vendor') || path.contains('/store')) {
      return AppRoutes.stores;
    }

    if (path.contains('/notifications')) {
      return AppRoutes.notifications;
    }

    if (type == 'ORDER') {
      return AppRoutes.orders;
    }

    if (type == 'STORE') {
      return AppRoutes.stores;
    }

    if (type == 'PROMOTION') {
      return AppRoutes.products;
    }

    return AppRoutes.notifications;
  }
}
