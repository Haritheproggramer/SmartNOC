enum AppRole { user, officer }

extension AppRoleX on AppRole {
  String get label => switch (this) {
        AppRole.user => 'User',
        AppRole.officer => 'Officer',
      };

  String get routeBase => switch (this) {
        AppRole.user => '/user',
        AppRole.officer => '/officer',
      };

  static AppRole fromString(String value) {
    return switch (value.toLowerCase()) {
      'officer' => AppRole.officer,
      _ => AppRole.user,
    };
  }
}
