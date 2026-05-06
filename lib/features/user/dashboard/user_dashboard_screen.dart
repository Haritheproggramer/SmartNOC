import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_stat_card.dart';
import '../../../features/auth/services/auth_controller.dart';
import '../../../features/shared/models/app_priority.dart';
import '../../../features/shared/models/app_status.dart';
import '../../../features/shared/models/application_record.dart';
import '../../../features/shared/services/noc_repository.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final auth = context.watch<AuthController>();
    final profile = auth.currentProfile;
    final repository = context.read<NocRepository>();

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder(
      future: repository.fetchUserStats(profile.id),
      builder: (context, statsSnapshot) {
        return StreamBuilder<List<ApplicationRecord>>(
          stream: repository.watchApplicationsForUser(profile.id),
          builder: (context, applicationsSnapshot) {
            final applications = applicationsSnapshot.data ?? const <ApplicationRecord>[];
            final stats = statsSnapshot.data;
            final latest = [...applications]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final recent = latest.take(3).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: 'Welcome back, ${profile.name.split(' ').first}',
                    subtitle: 'Your applications, alerts, and progress at a glance.',
                    action: AppButton(
                      label: 'New Application',
                      icon: Icons.add_circle_outline,
                      onPressed: () => context.go('/user/create'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 1280
                          ? 5
                          : width >= 980
                              ? 3
                              : width >= 640
                                  ? 2
                                  : 1;
                      final itemWidth = (width - (columns - 1) * 16) / columns;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: AppStatCard(
                              title: 'Total Applications',
                              value: '${stats?.total ?? applications.length}',
                              icon: Icons.folder_copy_outlined,
                              tint: colors.accent,
                              subtitle: 'All requests submitted by you',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: AppStatCard(
                              title: 'Pending',
                              value: '${stats?.pending ?? applications.where((item) => item.status == AppStatus.pending || item.status == AppStatus.underReview).length}',
                              icon: Icons.schedule_outlined,
                              tint: colors.warning,
                              subtitle: 'Waiting for officer review',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: AppStatCard(
                              title: 'Approved',
                              value: '${stats?.approved ?? applications.where((item) => item.status == AppStatus.approved).length}',
                              icon: Icons.verified_outlined,
                              tint: colors.success,
                              subtitle: 'Successfully cleared',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: AppStatCard(
                              title: 'Declined',
                              value: '${stats?.declined ?? applications.where((item) => item.status == AppStatus.declined).length}',
                              icon: Icons.cancel_outlined,
                              tint: colors.danger,
                              subtitle: 'Requires a revision',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: AppStatCard(
                              title: 'High Priority',
                              value: '${applications.where((item) => item.priority == AppPriority.high).length}',
                              icon: Icons.local_fire_department_outlined,
                              tint: colors.danger,
                              subtitle: 'Needs quick attention',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const AppSectionHeader(
                    title: 'Recent applications',
                    subtitle: 'The latest submissions from your account.',
                  ),
                  const SizedBox(height: 16),
                  if (applicationsSnapshot.connectionState == ConnectionState.waiting)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                  else if (recent.isEmpty)
                    AppEmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No applications yet',
                      message: 'Create your first fire NOC application to get started.',
                      actionLabel: 'Create application',
                      onAction: () => context.go('/user/create'),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final columns = width >= 1100 ? 3 : width >= 720 ? 2 : 1;
                        final itemWidth = (width - (columns - 1) * 16) / columns;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: recent
                              .map(
                                (application) => SizedBox(
                                  width: itemWidth,
                                  child: _ApplicationCard(
                                    application: application,
                                    onTap: () => _showApplicationDialog(context, application),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application, required this.onTap});

  final ApplicationRecord application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  application.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              AppBadge.priority(application.priority),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            application.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppBadge.status(application.status),
              _MetaChip(icon: Icons.category_outlined, label: application.category),
              _MetaChip(icon: Icons.place_outlined, label: application.location),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            DateFormat('dd MMM yyyy, hh:mm a').format(application.createdAt),
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Chip(
      avatar: Icon(icon, size: 16, color: colors.textSecondary),
      label: Text(label),
      side: BorderSide(color: colors.border),
      backgroundColor: colors.surfaceSoft,
    );
  }
}

Future<void> _showApplicationDialog(BuildContext context, ApplicationRecord application) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final colors = AppColors.of(context);
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        application.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AppBadge.priority(application.priority),
                    AppBadge.status(application.status),
                    _meta(context, application.category),
                    _meta(context, application.location),
                  ],
                ),
                const SizedBox(height: 18),
                Text(application.description, style: const TextStyle(height: 1.6)),
                const SizedBox(height: 18),
                Text(
                  'Submitted on ${DateFormat('dd MMM yyyy, hh:mm a').format(application.createdAt)}',
                  style: TextStyle(color: colors.textSecondary),
                ),
                if (application.remarks != null && application.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Remarks', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(application.remarks!),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: 'Close',
                    icon: Icons.check,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _meta(BuildContext context, String value) {
  final colors = AppColors.of(context);
  return Chip(
    label: Text(value),
    backgroundColor: colors.surfaceSoft,
    side: BorderSide(color: colors.border),
  );
}
