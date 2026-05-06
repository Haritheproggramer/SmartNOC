import 'package:file_picker/file_picker.dart';

import '../models/app_notification.dart';
import '../models/app_priority.dart';
import '../models/app_role.dart';
import '../models/app_status.dart';
import '../models/app_user_profile.dart';
import '../models/application_record.dart';
import '../models/dashboard_stats.dart';

class AuthResult {
  const AuthResult({required this.profile});

  final AppUserProfile profile;
}

abstract class NocRepository {
  Future<AppUserProfile?> getCurrentProfile();

  Future<AppUserProfile?> getProfileById(String profileId);

  Future<AuthResult> signIn({
    required String email,
    required String password,
  });

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required AppRole role,
  });

  Future<void> signOut();

  Future<DashboardStats> fetchUserStats(String userId);

  Future<DashboardStats> fetchOfficerStats();

  Stream<List<ApplicationRecord>> watchApplicationsForUser(String userId);

  Stream<List<ApplicationRecord>> watchAllApplications();

  Future<List<ApplicationRecord>> fetchApplicationsForUser(String userId);

  Future<List<ApplicationRecord>> fetchAllApplications();

  Future<ApplicationRecord?> getApplicationById(String applicationId);

  Future<ApplicationRecord> createApplication({
    required AppUserProfile profile,
    required String title,
    required String category,
    required String description,
    required String location,
    required AppPriority priority,
    PlatformFile? attachment,
  });

  Future<void> updateApplicationStatus({
    required String applicationId,
    required AppStatus status,
    required String remarks,
  });

  Stream<List<AppNotification>> watchNotifications(String userId);

  Future<List<AppNotification>> fetchNotifications(String userId);

  Future<void> markNotificationRead(String notificationId);
}
