import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/app_notification.dart';
import '../models/app_priority.dart';
import '../models/app_role.dart';
import '../models/app_status.dart';
import '../models/app_user_profile.dart';
import '../models/application_record.dart';
import '../models/dashboard_stats.dart';
import 'noc_repository.dart';

class SupabaseNocRepository implements NocRepository {
  SupabaseNocRepository(this.client);

  final SupabaseClient client;
  final Uuid _uuid = const Uuid();

  static const String _applicationBucket = 'application-documents';

  @override
  Future<AppUserProfile?> getCurrentProfile() async {
    // Wait for Supabase to restore the session from local storage.
    // client.auth.currentUser is null until the first auth state change fires.
    final session = client.auth.currentSession;
    if (session == null) {
      // No stored session – user is not logged in
      return null;
    }
    final authUser = client.auth.currentUser;
    if (authUser == null) {
      return null;
    }
    return getProfileById(authUser.id);
  }

  @override
  Future<AppUserProfile?> getProfileById(String profileId) async {
    final row = await client
        .from('profiles')
        .select()
        .eq('id', profileId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return AppUserProfile.fromMap(Map<String, dynamic>.from(row));
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(email: email.trim(), password: password);
    final profile = await getCurrentProfile();
    if (profile == null) {
      throw StateError('Profile not found after login.');
    }
    return AuthResult(profile: profile);
  }

  @override
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim(), 'role': role.name},
    );

    final authUser = response.user ?? client.auth.currentUser;
    if (authUser == null) {
      throw StateError('Unable to create account.');
    }

    await client.from('profiles').upsert({
      'id': authUser.id,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': role.name,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (response.session == null) {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    }

    final profile = await getCurrentProfile();
    if (profile != null) {
      return AuthResult(profile: profile);
    }

    return AuthResult(
      profile: AppUserProfile(
        id: authUser.id,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: role,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> signOut() => client.auth.signOut();

  Future<List<AppUserProfile>> _fetchProfiles(Iterable<String> ids) async {
    final profiles = <AppUserProfile>[];
    for (final profileId in ids) {
      final profile = await getProfileById(profileId);
      if (profile != null) {
        profiles.add(profile);
      }
    }
    return profiles;
  }

  Future<List<ApplicationRecord>> _hydrateApplications(
    List<Map<String, dynamic>> rows,
  ) async {
    final profiles = await _fetchProfiles(rows.map((row) => row['user_id'] as String));
    final profilesById = {for (final profile in profiles) profile.id: profile};

    return rows.map((row) {
      final profile = profilesById[row['user_id'] as String];
      return ApplicationRecord.fromMap({
        ...row,
        'applicant_name': profile?.name ?? row['applicant_name'] ?? 'Applicant',
        'applicant_email': profile?.email ?? row['applicant_email'] ?? '',
      });
    }).toList();
  }

  Future<AppNotification> _notificationFromMap(Map<String, dynamic> row) async {
    return AppNotification.fromMap(row);
  }

  @override
  Future<DashboardStats> fetchUserStats(String userId) async {
    final applications = await fetchApplicationsForUser(userId);
    return _statsFromApplications(applications);
  }

  @override
  Future<DashboardStats> fetchOfficerStats() async {
    final applications = await fetchAllApplications();
    return _statsFromApplications(applications);
  }

  DashboardStats _statsFromApplications(List<ApplicationRecord> applications) {
    return DashboardStats(
      total: applications.length,
      pending: applications.where((application) => application.status == AppStatus.pending || application.status == AppStatus.underReview).length,
      approved: applications.where((application) => application.status == AppStatus.approved).length,
      declined: applications.where((application) => application.status == AppStatus.declined).length,
      highPriority: applications.where((application) => application.priority == AppPriority.high).length,
    );
  }

  @override
  Stream<List<ApplicationRecord>> watchApplicationsForUser(String userId) {
    return client
        .from('applications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((rows) => _hydrateApplications(rows.cast<Map<String, dynamic>>()));
  }

  @override
  Stream<List<ApplicationRecord>> watchAllApplications() {
    return client
        .from('applications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((rows) => _hydrateApplications(rows.cast<Map<String, dynamic>>()));
  }

  @override
  Future<List<ApplicationRecord>> fetchApplicationsForUser(String userId) async {
    final rows = await client
        .from('applications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return _hydrateApplications(rows.cast<Map<String, dynamic>>());
  }

  @override
  Future<List<ApplicationRecord>> fetchAllApplications() async {
    final rows = await client.from('applications').select().order('created_at', ascending: false);
    return _hydrateApplications(rows.cast<Map<String, dynamic>>());
  }

  @override
  Future<ApplicationRecord?> getApplicationById(String applicationId) async {
    final row = await client
        .from('applications')
        .select()
        .eq('id', applicationId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    final hydrated = await _hydrateApplications([Map<String, dynamic>.from(row)]);
    return hydrated.isEmpty ? null : hydrated.first;
  }

  @override
  Future<ApplicationRecord> createApplication({
    required AppUserProfile profile,
    required String title,
    required String category,
    required String description,
    required String location,
    required AppPriority priority,
    PlatformFile? attachment,
  }) async {
    final applicationId = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await client.from('applications').insert({
      'id': applicationId,
      'user_id': profile.id,
      'title': title.trim(),
      'description': description.trim(),
      'category': category.trim(),
      'location': location.trim(),
      'priority': priority.name,
      'status': AppStatus.pending.name,
      'image_url': null,
      'remarks': null,
      'created_at': now,
      'updated_at': now,
    });

    String? imageUrl;
    if (attachment != null && attachment.bytes != null) {
      final storagePath = '${profile.id}/$applicationId/${attachment.name}';
      final contentType = attachment.extension == null
          ? 'application/octet-stream'
          : 'application/${attachment.extension!.toLowerCase()}';
      await client.storage.from(_applicationBucket).uploadBinary(
            storagePath,
            attachment.bytes!,
            fileOptions: FileOptions(
              upsert: true,
              contentType: contentType,
            ),
          );
      imageUrl = client.storage.from(_applicationBucket).getPublicUrl(storagePath);
      await client
          .from('applications')
          .update({'image_url': imageUrl, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', applicationId);
    }

    final created = await getApplicationById(applicationId);
    if (created != null) {
      return created;
    }

    return ApplicationRecord(
      id: applicationId,
      userId: profile.id,
      applicantName: profile.name,
      applicantEmail: profile.email,
      title: title.trim(),
      description: description.trim(),
      category: category.trim(),
      location: location.trim(),
      priority: priority,
      status: AppStatus.pending,
      imageUrl: imageUrl,
      remarks: null,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  @override
  Future<void> updateApplicationStatus({
    required String applicationId,
    required AppStatus status,
    required String remarks,
  }) async {
    final application = await getApplicationById(applicationId);
    if (application == null) {
      throw StateError('Application not found.');
    }

    await client.from('applications').update({
      'status': status.label,
      'remarks': remarks.trim().isEmpty ? null : remarks.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', applicationId);

    await client.from('notifications').insert({
      'id': _uuid.v4(),
      'user_id': application.userId,
      'application_id': application.id,
      'title': '${status.label} update',
      'message': 'Your application "${application.title}" has been marked ${status.label}.',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((rows) => Future.wait(rows.cast<Map<String, dynamic>>().map(_notificationFromMap)));
  }

  @override
  Future<List<AppNotification>> fetchNotifications(String userId) async {
    final rows = await client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return Future.wait(rows.cast<Map<String, dynamic>>().map(_notificationFromMap));
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    await client.from('notifications').update({'is_read': true}).eq('id', notificationId);
  }
}
