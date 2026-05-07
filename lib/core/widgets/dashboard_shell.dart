import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/shared/models/app_role.dart';
import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.role,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    required this.title,
    required this.subtitle,
    required this.profileName,
    required this.profileInitials,
    required this.onLogout,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  final AppRole role;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final String title;
  final String subtitle;
  final String profileName;
  final String profileInitials;
  final VoidCallback onLogout;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final destinations = role == AppRole.user
        ? const [
            _Destination(Icons.dashboard_outlined, 'Dashboard'),
            _Destination(Icons.add_circle_outline, 'Create'),
            _Destination(Icons.folder_copy_outlined, 'My Applications'),
            _Destination(Icons.notifications_none_outlined, 'Notifications'),
          ]
        : const [
            _Destination(Icons.dashboard_outlined, 'Dashboard'),
            _Destination(Icons.fact_check_outlined, 'Applications'),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        // mobile: <700, tablet: 700-1100, desktop: >1100
        final width = constraints.maxWidth;
        final isDesktop = width > 1100;
        final isMobile = width < 700;
        final navWidth = isDesktop ? 300.0 : 0.0;

        final shellBody = Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: _TopBar(
                title: title,
                subtitle: subtitle,
                profileName: profileName,
                profileInitials: profileInitials,
                onLogout: onLogout,
                onNotificationTap: onNotificationTap,
                notificationCount: notificationCount,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: child,
              ),
            ),
          ],
        );

        if (isDesktop) {
          return Scaffold(
            backgroundColor: colors.background,
            body: SafeArea(
              child: Row(
                children: [
                  Container(
                    width: navWidth,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _BrandBlock(role: role),
                        const SizedBox(height: 16),
                        Expanded(
                          child: NavigationRail(
                            selectedIndex: selectedIndex,
                            onDestinationSelected: onDestinationSelected,
                            labelType: NavigationRailLabelType.all,
                            backgroundColor: Colors.transparent,
                            destinations: destinations
                                .map(
                                  (destination) => NavigationRailDestination(
                                    icon: Icon(destination.icon),
                                    selectedIcon: Icon(destination.icon, color: colors.accent),
                                    label: Text(destination.label),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        // Fixed actions at bottom of sidebar
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                tooltip: 'Collapse',
                                onPressed: () {},
                                icon: const Icon(Icons.chevron_left_rounded),
                              ),
                              IconButton(
                                tooltip: 'Logout',
                                onPressed: onLogout,
                                icon: const Icon(Icons.logout_rounded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: shellBody),
                ],
              ),
            ),
          );
        }
        // Mobile/tablet: show bottom nav and ensure content has bottom padding
        final bottomNav = NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations
              .map(
                (destination) => NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.icon, color: colors.accent),
                  label: destination.label,
                ),
              )
              .toList(),
        );

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Padding(
              // Add bottom padding so content doesn't hide behind bottom nav on mobile
              padding: EdgeInsets.only(bottom: isMobile ? 88 : 20),
              child: shellBody,
            ),
          ),
          bottomNavigationBar: bottomNav,
        );
      },
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SmartNOC',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Text(
                  role == AppRole.user ? 'User workspace' : 'Officer workspace',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.profileName,
    required this.profileInitials,
    required this.onLogout,
    required this.notificationCount,
    this.onNotificationTap,
  });

  final String title;
  final String subtitle;
  final String profileName;
  final String profileInitials;
  final VoidCallback onLogout;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final themeController = context.watch<ThemeController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        // compact on small screens (mobile)
        final compact = constraints.maxWidth < 700;
        final searchField = TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: colors.surfaceSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.border),
            ),
          ),
        );

        final trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: themeController.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
              onPressed: () => themeController.toggleTheme(),
              icon: Icon(
                themeController.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
            ),
            IconButton(
              tooltip: 'Notifications',
              onPressed: onNotificationTap,
              icon: Badge(
                isLabelVisible: notificationCount > 0,
                label: Text('$notificationCount'),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: profileName,
              onSelected: (value) {
                if (value == 'logout') {
                  onLogout();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: colors.accent.withValues(alpha: 0.14),
                    child: Text(
                      profileInitials,
                      style: TextStyle(
                        color: colors.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 10),
                    Text(
                      profileName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );

        if (compact) {
          // Mobile: show title & compact trailing; hide large search field
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(color: colors.textSecondary)),
                      ],
                    ),
                  ),
                  // compact search icon
                  IconButton(
                    tooltip: 'Search',
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
                  const SizedBox(width: 4),
                  trailing,
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(width: 340, child: searchField),
            const SizedBox(width: 12),
            trailing,
          ],
        );
      },
    );
  }
}
