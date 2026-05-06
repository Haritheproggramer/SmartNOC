import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/services/auth_controller.dart';
import 'features/shared/services/noc_repository.dart';

class SmartNocApp extends StatelessWidget {
  const SmartNocApp({
    super.key,
    required this.repository,
    required this.authController,
    required this.themeController,
  });

  final NocRepository repository;
  final AuthController authController;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NocRepository>.value(value: repository),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) => MaterialApp.router(
          title: 'SmartNOC',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: theme.themeMode,
          routerConfig: createAppRouter(authController),
        ),
      ),
    );
  }
}
