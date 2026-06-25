import '../../domain/entities/app_notification_entity.dart';

class AppNotificationModel extends AppNotificationEntity {
  const AppNotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    super.link,
    required super.isRead,
    super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      type: (json['type'] ?? 'SYSTEM').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? json['body'] ?? '').toString(),
      link: _nullableString(json['link'] ?? json['path']),
      isRead: _readState(json),
      createdAt: _date(json['createdAt'] ?? json['created_at']),
    );
  }

  static bool _readState(Map<String, dynamic> json) {
    final direct = json['isRead'] ?? json['is_read'] ?? json['read'];
    if (direct != null) return _bool(direct);

    final readAt = json['readAt'] ?? json['read_at'];
    if (_nullableString(readAt) != null) return true;

    final status = json['status']?.toString().toUpperCase();
    return status == 'READ';
  }

  static bool _bool(Object? value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }

  static DateTime? _date(Object? value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text)?.toLocal();
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
