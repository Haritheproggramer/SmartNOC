class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.applicationId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String applicationId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotification.fromMap(Map<String, dynamic> data) {
    return AppNotification(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      applicationId: data['application_id'] as String,
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      isRead: data['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'application_id': applicationId,
        'title': title,
        'message': message,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };

  AppNotification copyWith({
    String? id,
    String? userId,
    String? applicationId,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      applicationId: applicationId ?? this.applicationId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
