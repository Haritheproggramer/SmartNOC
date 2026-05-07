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

class OfficerDashboardScreen extends StatelessWidget {
  const OfficerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.currentProfile;
    final repository = context.read<NocRepository>();

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder(
      future: repository.fetchOfficerStats(),
      builder: (context, statsSnapshot) {
        return StreamBuilder<List<ApplicationRecord>>(
          stream: repository.watchAllApplications(),
          builder: (context, applicationsSnapshot) {
            final applications = applicationsSnapshot.data ?? const <ApplicationRecord>[];
            final latest = [...applications]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final stats = statsSnapshot.data;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action only - title is provided by the shell
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: 'View all applications',
                      icon: Icons.fact_check_outlined,
                      onPressed: () => context.go('/officer/applications'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final columns = width > 1100 ? 4 : (width >= 700 ? 2 : 1);
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
                              tint: AppColors.accent,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: AppStatCard(
                              title: 'Pending',
                              value: '${stats?.pending ?? applications.where((item) => item.status == AppStatus.pending || item.status == AppStatus.underReview).length}',
                              icon: Icons.schedule_outlined,
                              tint: AppColors.warning,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: AppStatCard(
                              title: 'Approved',
                              value: '${stats?.approved ?? applications.where((item) => item.status == AppStatus.approved).length}',
                              icon: Icons.verified_outlined,
                              tint: AppColors.success,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: AppStatCard(
                              title: 'Declined',
                              value: '${stats?.declined ?? applications.where((item) => item.status == AppStatus.declined).length}',
                              icon: Icons.cancel_outlined,
                              tint: AppColors.danger,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: AppStatCard(
                              title: 'High Priority',
                              value: '${stats?.highPriority ?? applications.where((item) => item.priority == AppPriority.high).length}',
                              icon: Icons.local_fire_department_outlined,
                              tint: AppColors.danger,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  if (applicationsSnapshot.connectionState == ConnectionState.waiting)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                  else if (latest.isEmpty)
                    const AppEmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No applications available',
                      message: 'Once users submit requests, they will appear here for officer review.',
                    )
                  else
                    Column(
                      children: latest
                          .take(4)
                          .map(
                            (application) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: AppCard(
                                onTap: () => context.go('/officer/review/${application.id}'),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: application.priority.color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Icon(Icons.local_fire_department_outlined, color: application.priority.color),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(application.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                                          const SizedBox(height: 4),
                                          Text(application.applicantName, style: const TextStyle(color: AppColors.textSecondary)),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: [
                                              AppBadge.priority(application.priority),
                                              AppBadge.status(application.status),
                                              _chip(application.category),
                                              _chip(application.location),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Icon(Icons.chevron_right_rounded),
                                        const SizedBox(height: 8),
                                        Text(DateFormat('dd MMM').format(application.createdAt), style: const TextStyle(color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
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

Widget _chip(String label) {
  return Chip(
    label: Text(label),
    backgroundColor: AppColors.surfaceSoft,
    side: const BorderSide(color: AppColors.border),
  );
}
