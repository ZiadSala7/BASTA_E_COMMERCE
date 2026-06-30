part of '../notifications_remote_datasource.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<AppNotificationModel>> getNotifications({
    int page = 1,
    int limit = 10,
  });

  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> updateFcmToken(String token);
}
