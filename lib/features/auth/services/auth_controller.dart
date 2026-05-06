import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../shared/models/app_role.dart';
import '../../shared/models/app_user_profile.dart';
import '../../shared/services/noc_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    unawaited(_bootstrap());
  }

  final NocRepository _repository;

  AppUserProfile? _currentProfile;
  bool _isBootstrapping = true;
  bool _isBusy = false;
  String? _errorMessage;
  String? _bootError;

  AppUserProfile? get currentProfile => _currentProfile;
  bool get isBootstrapping => _isBootstrapping;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  String? get bootError => _bootError;
  bool get isAuthenticated => _currentProfile != null;
  AppRole? get role => _currentProfile?.role;
  bool get isOfficer => role == AppRole.officer;
  bool get isUser => role == AppRole.user;
  bool get isDemoMode => _repository.runtimeType.toString().contains('Local');

  Future<void> _bootstrap() async {
    try {
      _currentProfile = await _repository.getCurrentProfile().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          // Timed out – treat as unauthenticated so router redirects to /login
          return null;
        },
      );
    } catch (error) {
      _bootError = error.toString();
      _currentProfile = null;
    } finally {
      _isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    try {
      final result = await _repository.signIn(email: email, password: password);
      _currentProfile = result.profile;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    _setBusy(true);
    try {
      final result = await _repository.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _currentProfile = result.profile;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() async {
    _setBusy(true);
    try {
      await _repository.signOut();
      _currentProfile = null;
      _errorMessage = null;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
