import 'app_role.dart';

class AppUserProfile {
  const AppUserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final AppRole role;
  final DateTime createdAt;

  factory AppUserProfile.fromMap(Map<String, dynamic> data) {
    return AppUserProfile(
      id: data['id'] as String,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? data['name'] as String
          : 'NOC User',
      email: data['email'] as String? ?? '',
      role: AppRoleX.fromString(data['role'] as String? ?? 'user'),
      createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'created_at': createdAt.toIso8601String(),
      };
}
