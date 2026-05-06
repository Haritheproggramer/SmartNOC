import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/screens/boot_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/services/auth_controller.dart';
import '../../features/officer/applications/officer_applications_screen.dart';
import '../../features/officer/dashboard/officer_dashboard_screen.dart';
import '../../features/officer/review/application_review_screen.dart';
import '../../features/shared/models/app_role.dart';
import '../../features/user/create_application/create_application_screen.dart';
import '../../features/user/dashboard/user_dashboard_screen.dart';
import '../../features/user/my_applications/my_applications_screen.dart';
import '../../features/user/notifications/user_notifications_screen.dart';
import '../widgets/dashboard_shell.dart';

GoRouter createAppRouter(AuthController authController) {
  return GoRouter(
    initialLocation: '/loading',
    refreshListenable: authController,
    redirect: (context, state) {
      final auth = authController;
      final location = state.uri.path;

      if (auth.isBootstrapping) {
        return location == '/loading' ? null : '/loading';
      }

      final isPublicRoute = location == '/login' || location == '/signup' || location == '/loading';
      if (!auth.isAuthenticated) {
        return isPublicRoute ? null : '/login';
      }

      final homeRoute = auth.isOfficer ? '/officer' : '/user';
      if (location == '/' || location == '/loading' || location == '/login' || location == '/signup') {
        return homeRoute;
      }

      if (auth.isUser && location.startsWith('/officer')) {
        return '/user';
      }

      if (auth.isOfficer && location.startsWith('/user')) {
        return '/officer';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const BootScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(initialMode: AuthScreenMode.login),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const LoginScreen(initialMode: AuthScreenMode.signUp),
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) => const _UserRoute(index: 0, child: UserDashboardScreen()),
      ),
      GoRoute(
        path: '/user/create',
        builder: (context, state) => const _UserRoute(index: 1, child: CreateApplicationScreen()),
      ),
      GoRoute(
        path: '/user/applications',
        builder: (context, state) => const _UserRoute(index: 2, child: MyApplicationsScreen()),
      ),
      GoRoute(
        path: '/user/notifications',
        builder: (context, state) => const _UserRoute(index: 3, child: UserNotificationsScreen()),
      ),
      GoRoute(
        path: '/officer',
        builder: (context, state) => const _OfficerRoute(index: 0, child: OfficerDashboardScreen()),
      ),
      GoRoute(
        path: '/officer/applications',
        builder: (context, state) => const _OfficerRoute(index: 1, child: OfficerApplicationsScreen()),
      ),
      GoRoute(
        path: '/officer/review/:id',
        builder: (context, state) => _OfficerRoute(
          index: 1,
          child: ApplicationReviewScreen(applicationId: state.pathParameters['id'] ?? ''),
        ),
      ),
    ],
  );
}

class _UserRoute extends StatelessWidget {
  const _UserRoute({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentProfile;
    return DashboardShell(
      role: AppRole.user,
      selectedIndex: index,
      title: switch (index) {
        0 => 'User Dashboard',
        1 => 'Create Application',
        2 => 'My Applications',
        _ => 'Notifications',
      },
      subtitle: switch (index) {
        0 => 'Track applications, review their status, and stay ahead of NOC approvals.',
        1 => 'Submit a new NOC request with automatic priority detection.',
        2 => 'Search, filter, and review everything you have submitted.',
        _ => 'Realtime updates when officers change the status of your applications.',
      },
      profileName: user?.name ?? 'User',
      profileInitials: _initials(user?.name ?? 'User'),
      notificationCount: 0,
      onDestinationSelected: (value) {
        switch (value) {
          case 0:
            context.go('/user');
            return;
          case 1:
            context.go('/user/create');
            return;
          case 2:
            context.go('/user/applications');
            return;
          case 3:
            context.go('/user/notifications');
            return;
        }
      },
      onNotificationTap: () => context.go('/user/notifications'),
      onLogout: () async {
        await auth.signOut();
        if (context.mounted) {
          context.go('/login');
        }
      },
      child: child,
    );
  }
}

class _OfficerRoute extends StatelessWidget {
  const _OfficerRoute({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentProfile;
    return DashboardShell(
      role: AppRole.officer,
      selectedIndex: index,
      title: switch (index) {
        0 => 'Officer Dashboard',
        _ => 'Applications',
      },
      subtitle: switch (index) {
        0 => 'Review pending requests, high-priority alerts, and status trends.',
        _ => 'Sort, filter, and action all submitted applications from one place.',
      },
      profileName: user?.name ?? 'Officer',
      profileInitials: _initials(user?.name ?? 'Officer'),
      notificationCount: 0,
      onDestinationSelected: (value) {
        switch (value) {
          case 0:
            context.go('/officer');
            return;
          case 1:
            context.go('/officer/applications');
            return;
        }
      },
      onNotificationTap: () => context.go('/officer/applications'),
      onLogout: () async {
        await auth.signOut();
        if (context.mounted) {
          context.go('/login');
        }
      },
      child: child,
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) {
    return 'U';
  }
  if (parts.length == 1) {
    return parts.first.isEmpty ? 'U' : parts.first[0].toUpperCase();
  }
  final first = parts.first.isEmpty ? 'U' : parts.first[0];
  final last = parts.last.isEmpty ? 'U' : parts.last[0];
  return (first + last).toUpperCase();
}
