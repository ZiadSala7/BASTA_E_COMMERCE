class AppNotificationEntity {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? link;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.link,
    required this.isRead,
    this.createdAt,
  });

  AppNotificationEntity copyWith({bool? isRead}) {
    return AppNotificationEntity(
      id: id,
      type: type,
      title: title,
      message: message,
      link: link,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
