import '../entities/app_notification_entity.dart';

abstract class NotificationsRepository {
  Future<List<AppNotificationEntity>> getNotifications({
    int page = 1,
    int limit = 10,
  });

  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> updateFcmToken(String token);
}
