import 'dart:convert';
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static const String channelId = 'ionbit_alert_notifications';
  static const String channelName = 'Notifications';
  static const String channelDescription = 'Order and account notifications';
  static const String androidNotificationIcon = 'ic_notification';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

  static Future<void> initialize() async {
    if (_initialized) return;

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(androidNotificationIcon),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: initializationSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    await initialize();

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> configureForegroundPresentation() {
    return FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static void listenForForegroundMessages() {
    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen(
      showRemoteMessage,
    );
  }

  static Future<void> showRemoteMessage(RemoteMessage message) async {
    await initialize();

    final title = _titleFromMessage(message);
    final body = _bodyFromMessage(message);
    if (title == null && body == null) return;

    await _plugin.show(
      id: _notificationIdFor(message),
      title: title ?? channelName,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          icon: androidNotificationIcon,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static int _notificationIdFor(RemoteMessage message) {
    final source = message.messageId ?? jsonEncode(message.data);
    return source.hashCode & 0x7fffffff;
  }

  static String? _titleFromMessage(RemoteMessage message) {
    return _firstNonEmpty([
      message.notification?.title,
      message.data['title'],
      message.data['name'],
      message.data['notification_title'],
      _nestedDataValue(message, 'title'),
      _nestedDataValue(message, 'notification_title'),
    ]);
  }

  static String? _bodyFromMessage(RemoteMessage message) {
    return _firstNonEmpty([
      message.notification?.body,
      message.data['body'],
      message.data['message'],
      message.data['content'],
      message.data['notification_body'],
      _nestedDataValue(message, 'body'),
      _nestedDataValue(message, 'message'),
      _nestedDataValue(message, 'content'),
      _nestedDataValue(message, 'notification_body'),
    ]);
  }

  static Object? _nestedDataValue(RemoteMessage message, String key) {
    const nestedKeys = ['notification', 'data', 'payload'];

    for (final nestedKey in nestedKeys) {
      final nested = _asMap(message.data[nestedKey]);
      final value = nested?[key];
      if (value != null) return value;
    }

    return null;
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  static String? _firstNonEmpty(Iterable<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }
}
