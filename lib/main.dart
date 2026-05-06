import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/app_config.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/services/auth_controller.dart';
import 'features/shared/services/local_noc_repository.dart';
import 'features/shared/services/noc_repository.dart';
import 'features/shared/services/supabase_noc_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NocRepository repository;
  if (AppConfig.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    repository = SupabaseNocRepository(Supabase.instance.client);
  } else {
    repository = LocalNocRepository();
  }

  final authController = AuthController(repository);
  final themeController = ThemeController();
  await themeController.initialize();

  runApp(
    SmartNocApp(
      repository: repository,
      authController: authController,
      themeController: themeController,
    ),
  );
}
