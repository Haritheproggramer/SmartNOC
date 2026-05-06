import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/app_notification.dart';
import '../models/app_priority.dart';
import '../models/app_role.dart';
import '../models/app_status.dart';
import '../models/app_user_profile.dart';
import '../models/application_record.dart';
import '../models/dashboard_stats.dart';
import 'noc_repository.dart';

class LocalNocRepository implements NocRepository {
  LocalNocRepository() {
    unawaited(_ensureInitialized());
  }

  static const String _profilesKey = 'smartnoc_profiles';
  static const String _passwordsKey = 'smartnoc_passwords';
  static const String _applicationsKey = 'smartnoc_applications';
  static const String _notificationsKey = 'smartnoc_notifications';
  static const String _currentUserIdKey = 'smartnoc_current_user_id';

  final Uuid _uuid = const Uuid();
  final StreamController<void> _applicationUpdates =
      StreamController<void>.broadcast();
  final StreamController<void> _notificationUpdates =
      StreamController<void>.broadcast();
  final StreamController<void> _profileUpdates =
      StreamController<void>.broadcast();

  Future<SharedPreferences>? _prefsFuture;
  List<AppUserProfile> _profiles = <AppUserProfile>[];
  Map<String, String> _passwords = <String, String>{};
  List<ApplicationRecord> _applications = <ApplicationRecord>[];
  List<AppNotification> _notifications = <AppNotification>[];
  String? _currentUserId;
  bool _initialized = false;

  Future<SharedPreferences> _prefs() {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    final prefs = await _prefs();
    _currentUserId = prefs.getString(_currentUserIdKey);
    _profiles = _readProfiles(prefs.getString(_profilesKey));
    _passwords = _readPasswordMap(prefs.getString(_passwordsKey));
    _applications = _readApplications(prefs.getString(_applicationsKey));
    _notifications = _readNotifications(prefs.getString(_notificationsKey));

    if (_profiles.isEmpty) {
      _seedData();
      await _save();
    }

    _initialized = true;
  }

  void _seedData() {
    final officer = AppUserProfile(
      id: _uuid.v4(),
      name: 'Aarav Mehta',
      email: 'officer@nocverse.com',
      role: AppRole.officer,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    );
    final user = AppUserProfile(
      id: _uuid.v4(),
      name: 'Nisha Patel',
      email: 'user@nocverse.com',
      role: AppRole.user,
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
    );

    _profiles = [officer, user];
    _passwords = {
      officer.email.toLowerCase(): 'Officer1234!',
      user.email.toLowerCase(): 'User1234!',
    };

    _applications = [
      ApplicationRecord(
        id: _uuid.v4(),
        userId: user.id,
        applicantName: user.name,
        applicantEmail: user.email,
        title: 'Fire safety renewal',
        description: 'Routine renewal for a small office floor.',
        category: 'Renewal',
        location: 'Pune, Maharashtra',
        priority: AppPriority.low,
        status: AppStatus.approved,
        imageUrl: null,
        remarks: 'All documentation in order.',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      ApplicationRecord(
        id: _uuid.v4(),
        userId: user.id,
        applicantName: user.name,
        applicantEmail: user.email,
        title: 'Restaurant kitchen compliance review',
        description: 'Commercial kitchen needs a compliance review.',
        category: 'Restaurant',
        location: 'Mumbai, Maharashtra',
        priority: AppPriority.medium,
        status: AppStatus.underReview,
        imageUrl: null,
        remarks: null,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ApplicationRecord(
        id: _uuid.v4(),
        userId: user.id,
        applicantName: user.name,
        applicantEmail: user.email,
        title: 'Gas leakage inspection',
        description: 'Potential gas leakage near the storage section.',
        category: 'Emergency',
        location: 'Navi Mumbai, Maharashtra',
        priority: AppPriority.high,
        status: AppStatus.pending,
        imageUrl: null,
        remarks: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];

    _notifications = [
      AppNotification(
        id: _uuid.v4(),
        userId: user.id,
        applicationId: _applications.first.id,
        title: 'Application approved',
        message: 'Your renewal application was approved by the officer.',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: user.id,
        applicationId: _applications[1].id,
        title: 'Application under review',
        message: 'Your restaurant review is being checked by an officer.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      ),
    ];
  }

  List<AppUserProfile> _readProfiles(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <AppUserProfile>[];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(AppUserProfile.fromMap)
        .toList();
  }

  Map<String, String> _readPasswordMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <String, String>{};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  List<ApplicationRecord> _readApplications(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <ApplicationRecord>[];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(ApplicationRecord.fromMap)
        .toList();
  }

  List<AppNotification> _readNotifications(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <AppNotification>[];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(AppNotification.fromMap)
        .toList();
  }

  Future<void> _save() async {
    final prefs = await _prefs();
    await prefs.setString(
      _profilesKey,
      jsonEncode(_profiles.map((profile) => profile.toMap()).toList()),
    );
    await prefs.setString(_passwordsKey, jsonEncode(_passwords));
    await prefs.setString(
      _applicationsKey,
      jsonEncode(_applications.map((application) => application.toMap()).toList()),
    );
    await prefs.setString(
      _notificationsKey,
      jsonEncode(_notifications.map((notification) => notification.toMap()).toList()),
    );
    if (_currentUserId == null) {
      await prefs.remove(_currentUserIdKey);
    } else {
      await prefs.setString(_currentUserIdKey, _currentUserId!);
    }
  }

  AppUserProfile? _profileById(String profileId) {
    for (final profile in _profiles) {
      if (profile.id == profileId) {
        return profile;
      }
    }
    return null;
  }

  ApplicationRecord? _applicationById(String applicationId) {
    for (final application in _applications) {
      if (application.id == applicationId) {
        return application;
      }
    }
    return null;
  }

  List<ApplicationRecord> _applicationsForUser(String userId) {
    final result = _applications.where((application) => application.userId == userId).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  List<AppNotification> _notificationsForUser(String userId) {
    final result = _notifications.where((notification) => notification.userId == userId).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
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

  void _emitApplicationUpdate() {
    if (!_applicationUpdates.isClosed) {
      _applicationUpdates.add(null);
    }
  }

  void _emitNotificationUpdate() {
    if (!_notificationUpdates.isClosed) {
      _notificationUpdates.add(null);
    }
  }

  void _emitProfileUpdate() {
    if (!_profileUpdates.isClosed) {
      _profileUpdates.add(null);
    }
  }

  @override
  Future<AppUserProfile?> getCurrentProfile() async {
    await _ensureInitialized();
    if (_currentUserId == null) {
      return null;
    }
    return _profileById(_currentUserId!);
  }

  @override
  Future<AppUserProfile?> getProfileById(String profileId) async {
    await _ensureInitialized();
    return _profileById(profileId);
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    final normalizedEmail = email.trim().toLowerCase();
    final profile = _profiles.firstWhere(
      (item) => item.email.toLowerCase() == normalizedEmail,
      orElse: () => throw StateError('No account found for that email.'),
    );
    final savedPassword = _passwords[normalizedEmail];
    if (savedPassword == null || savedPassword != password) {
      throw StateError('Invalid email or password.');
    }

    _currentUserId = profile.id;
    await _save();
    _emitProfileUpdate();
    return AuthResult(profile: profile);
  }

  @override
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    await _ensureInitialized();
    final normalizedEmail = email.trim().toLowerCase();
    if (_profiles.any((profile) => profile.email.toLowerCase() == normalizedEmail)) {
      throw StateError('An account already exists for that email.');
    }

    final profile = AppUserProfile(
      id: _uuid.v4(),
      name: name.trim(),
      email: normalizedEmail,
      role: role,
      createdAt: DateTime.now(),
    );
    _profiles = [..._profiles, profile];
    _passwords[normalizedEmail] = password;
    _currentUserId = profile.id;
    await _save();
    _emitProfileUpdate();
    return AuthResult(profile: profile);
  }

  @override
  Future<void> signOut() async {
    await _ensureInitialized();
    _currentUserId = null;
    await _save();
    _emitProfileUpdate();
  }

  @override
  Future<DashboardStats> fetchUserStats(String userId) async {
    await _ensureInitialized();
    return _statsFromApplications(_applicationsForUser(userId));
  }

  @override
  Future<DashboardStats> fetchOfficerStats() async {
    await _ensureInitialized();
    return _statsFromApplications(_applications);
  }

  @override
  Stream<List<ApplicationRecord>> watchApplicationsForUser(String userId) async* {
    await _ensureInitialized();
    yield _applicationsForUser(userId);
    yield* _applicationUpdates.stream.map((_) => _applicationsForUser(userId));
  }

  @override
  Stream<List<ApplicationRecord>> watchAllApplications() async* {
    await _ensureInitialized();
    final all = [..._applications]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    yield all;
    yield* _applicationUpdates.stream.map((_) {
      final result = [..._applications]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    });
  }

  @override
  Future<List<ApplicationRecord>> fetchApplicationsForUser(String userId) async {
    await _ensureInitialized();
    return _applicationsForUser(userId);
  }

  @override
  Future<List<ApplicationRecord>> fetchAllApplications() async {
    await _ensureInitialized();
    final result = [..._applications]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  @override
  Future<ApplicationRecord?> getApplicationById(String applicationId) async {
    await _ensureInitialized();
    return _applicationById(applicationId);
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
    await _ensureInitialized();
    final application = ApplicationRecord(
      id: _uuid.v4(),
      userId: profile.id,
      applicantName: profile.name,
      applicantEmail: profile.email,
      title: title.trim(),
      description: description.trim(),
      category: category.trim(),
      location: location.trim(),
      priority: priority,
      status: AppStatus.pending,
      imageUrl: attachment?.name,
      remarks: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _applications = [..._applications, application];
    await _save();
    _emitApplicationUpdate();
    return application;
  }

  @override
  Future<void> updateApplicationStatus({
    required String applicationId,
    required AppStatus status,
    required String remarks,
  }) async {
    await _ensureInitialized();
    final application = _applicationById(applicationId);
    if (application == null) {
      throw StateError('Application not found.');
    }

    final updated = application.copyWith(
      status: status,
      remarks: remarks.trim().isEmpty ? null : remarks.trim(),
      updatedAt: DateTime.now(),
    );
    _applications = [
      for (final item in _applications)
        if (item.id == applicationId) updated else item,
    ];
    _notifications = [
      AppNotification(
        id: _uuid.v4(),
        userId: application.userId,
        applicationId: application.id,
        title: '${status.label} update',
        message:
            'Your application "${application.title}" has been marked ${status.label}.',
        isRead: false,
        createdAt: DateTime.now(),
      ),
      ..._notifications,
    ];
    await _save();
    _emitApplicationUpdate();
    _emitNotificationUpdate();
  }

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) async* {
    await _ensureInitialized();
    yield _notificationsForUser(userId);
    yield* _notificationUpdates.stream.map((_) => _notificationsForUser(userId));
  }

  @override
  Future<List<AppNotification>> fetchNotifications(String userId) async {
    await _ensureInitialized();
    return _notificationsForUser(userId);
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    await _ensureInitialized();
    _notifications = [
      for (final notification in _notifications)
        if (notification.id == notificationId)
          notification.copyWith(isRead: true)
        else
          notification,
    ];
    await _save();
    _emitNotificationUpdate();
  }
}
