import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/notifications/local_notification_service.dart';
import '../../../../core/notifications/notification_navigator.dart';
import '../repositories/notifications_repository.dart';

class NotificationsController extends ChangeNotifier {
  final NotificationsRepository _repository;
  final FirebaseMessaging _messaging;

  NotificationsController(this._repository, {FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  int _unreadCount = 0;
  bool _isRefreshing = false;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  Future<void> refreshUnreadCount() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      final count = await _repository.getUnreadCount();
      setUnreadCount(count);
    } catch (_) {
      // Keep the previous badge value when the refresh fails.
    } finally {
      _isRefreshing = false;
    }
  }

  void setUnreadCount(int count) {
    final safeCount = count < 0 ? 0 : count;
    if (_unreadCount == safeCount) return;

    _unreadCount = safeCount;
    notifyListeners();
  }

  void decrementUnread() {
    setUnreadCount(_unreadCount - 1);
  }

  Future<void> setupAfterLogin({String? role}) async {
    if (role != null && role.toUpperCase() != 'CUSTOMER') return;

    await refreshUnreadCount();
    await _registerFcmToken();
    _listenForPushEvents();
    await checkInitialMessage();
  }

  Future<void> _registerFcmToken() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await LocalNotificationService.requestPermissions();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _repository.updateFcmToken(token);
      }

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
        if (token.isNotEmpty) {
          _repository.updateFcmToken(token);
        }
      });
    } catch (_) {
      // Push registration should not block login.
    }
  }

  void _listenForPushEvents() {
    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen((_) {
      refreshUnreadCount();
    });

    _openedAppSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        refreshUnreadCount();
        _navigateFromMessage(message);
      },
    );
  }

  /// Handles a notification that launched the app from a terminated state.
  Future<void> checkInitialMessage() async {
    try {
      final message = await _messaging.getInitialMessage();
      if (message != null) {
        _navigateFromMessage(message);
      }
    } catch (_) {}
  }

  void _navigateFromMessage(RemoteMessage message) {
    if (message.data.isEmpty) return;
    NotificationNavigator.handleNotificationTap(message.data);
  }

  @override
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _openedAppSubscription?.cancel();
    super.dispose();
  }
}
