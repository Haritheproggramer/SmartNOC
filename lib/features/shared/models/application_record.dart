import 'app_priority.dart';
import 'app_status.dart';

class ApplicationRecord {
  const ApplicationRecord({
    required this.id,
    required this.userId,
    required this.applicantName,
    required this.applicantEmail,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.remarks,
  });

  final String id;
  final String userId;
  final String applicantName;
  final String applicantEmail;
  final String title;
  final String description;
  final String category;
  final String location;
  final AppPriority priority;
  final AppStatus status;
  final String? imageUrl;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ApplicationRecord.fromMap(Map<String, dynamic> data) {
    return ApplicationRecord(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      applicantName: (data['applicant_name'] as String?)?.trim().isNotEmpty == true
          ? data['applicant_name'] as String
          : 'Applicant',
      applicantEmail: data['applicant_email'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      location: data['location'] as String? ?? '',
      priority: AppPriorityX.fromString(data['priority'] as String? ?? 'Low'),
      status: AppStatusX.fromString(data['status'] as String? ?? 'Pending'),
      imageUrl: data['image_url'] as String?,
      remarks: data['remarks'] as String?,
      createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(data['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'applicant_name': applicantName,
        'applicant_email': applicantEmail,
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'priority': priority.name,
        'status': status.name,
        'image_url': imageUrl,
        'remarks': remarks,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ApplicationRecord copyWith({
    String? id,
    String? userId,
    String? applicantName,
    String? applicantEmail,
    String? title,
    String? description,
    String? category,
    String? location,
    AppPriority? priority,
    AppStatus? status,
    String? imageUrl,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearImageUrl = false,
    bool clearRemarks = false,
  }) {
    return ApplicationRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      applicantName: applicantName ?? this.applicantName,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      remarks: clearRemarks ? null : (remarks ?? this.remarks),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
