part of '../notifications_remote_datasource.dart';

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final DioConsumer _dioConsumer;

  const NotificationsRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _dioConsumer = dioConsumer;

  @override
  Future<List<AppNotificationModel>> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dioConsumer.get(
        Endpoints.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );

      return _listFromResponse(response.data)
          .whereType<Map>()
          .map(
            (item) => AppNotificationModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } on DioException catch (error, stackTrace) {
      log('Get notifications failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error, 'Could not load notifications.'));
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dioConsumer.get(
        Endpoints.unreadNotificationsCount,
      );
      final body = _asMap(response.data);
      final data = _asMap(body['data']);
      final value =
          data['unreadCount'] ??
          data['unread_count'] ??
          data['count'] ??
          data['total'] ??
          body['unreadCount'] ??
          body['unread_count'] ??
          body['count'] ??
          body['total'] ??
          0;

      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    } on DioException catch (error, stackTrace) {
      log(
        'Get unread notifications failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_messageFromDio(error, 'Could not load unread count.'));
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dioConsumer.patch(Endpoints.markNotificationRead(notificationId));
    } on DioException catch (error, stackTrace) {
      log(
        'Mark notification read failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_messageFromDio(error, 'Could not update notification.'));
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    try {
      await _dioConsumer.patch(
        Endpoints.updateFcmToken,
        data: {'token': token},
      );
    } on DioException catch (error, stackTrace) {
      log('Update FCM token failed', error: error, stackTrace: stackTrace);
      throw Exception(
        _messageFromDio(error, 'Could not register device token.'),
      );
    }
  }

  List<dynamic> _listFromResponse(dynamic data) {
    if (data is List) return data;
    final body = _asMap(data);
    final direct = body['data'] ?? body['notifications'];
    if (direct is List) return direct;

    final nested = _asMap(body['data']);
    final nestedItems = nested['notifications'] ?? nested['items'];
    if (nestedItems is List) return nestedItems;

    return const <dynamic>[];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  String _messageFromDio(DioException error, String fallback) {
    final data = error.response?.data;
    final map = _asMap(data);
    final message = map['message']?.toString();
    if (message != null && message.isNotEmpty) return message;

    if (error.response?.statusCode == 401) {
      return 'Please log in to view notifications.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The server took too long to respond. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your internet connection.';
    }

    return error.message ?? fallback;
  }
}
