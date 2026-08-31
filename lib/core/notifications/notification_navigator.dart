import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/domain/entities/app_notification_entity.dart';
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
    final title = data['title']?.toString() ?? '';
    final body = data['body']?.toString() ?? data['message']?.toString() ?? '';
    final id = data['id']?.toString() ?? data['notificationId']?.toString() ?? '';

    final lowerPath = path.toLowerCase();
    if (lowerPath == '/notification-details' ||
        lowerPath == '/notifications/details' ||
        (lowerPath.isEmpty && (title.isNotEmpty || body.isNotEmpty) && type == 'SYSTEM')) {
      if (title.isNotEmpty || body.isNotEmpty) {
        sl<GoRouter>().push(
          AppRoutes.notificationDetails,
          extra: AppNotificationEntity(
            id: id.isNotEmpty ? id : 'push_${DateTime.now().millisecondsSinceEpoch}',
            type: type.isNotEmpty ? type : 'SYSTEM',
            title: title.isNotEmpty ? title : 'إشعار جديد',
            message: body,
            link: path,
            isRead: true,
            createdAt: DateTime.now(),
          ),
        );
        return;
      }
    }

    final orderMatch = RegExp(r'/orders/([a-zA-Z0-9_\-]+)').firstMatch(path);
    if (orderMatch != null) {
      final orderId = orderMatch.group(1)!;
      sl<GoRouter>().push(AppRoutes.orderDetails, extra: orderId);
      return;
    }

    final route = _routeFor(path, type);
    debugPrint(
      'Navigating from notification -> Type: $type, Path: $path, Route: $route',
    );

    sl<GoRouter>().push(route);
  }

  static String _routeFor(String path, String type) {
    final lowerPath = path.toLowerCase();

    if (lowerPath.contains('coupon') ||
        lowerPath.contains('reward') ||
        lowerPath.contains('/profileuser/coupons')) {
      return AppRoutes.coupons;
    }

    if (lowerPath.contains('/orders')) {
      return AppRoutes.orders;
    }

    if (lowerPath.contains('/vendor') || lowerPath.contains('/store')) {
      return AppRoutes.stores;
    }

    if (lowerPath.contains('/notifications')) {
      return AppRoutes.notifications;
    }

    if (type == 'COUPON' ||
        type == 'COUPONS' ||
        type == 'REWARD' ||
        type == 'REWARDS' ||
        type == 'REFERRAL') {
      return AppRoutes.coupons;
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
