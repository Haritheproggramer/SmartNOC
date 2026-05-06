import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../features/auth/services/auth_controller.dart';
import '../../../features/shared/models/app_status.dart';
import '../../../features/shared/models/application_record.dart';
import '../../../features/shared/services/noc_repository.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final _searchController = TextEditingController();
  AppStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.currentProfile;
    final repository = context.read<NocRepository>();

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<ApplicationRecord>>(
      stream: repository.watchApplicationsForUser(profile.id),
      builder: (context, snapshot) {
        final applications = snapshot.data ?? const <ApplicationRecord>[];
        final query = _searchController.text.trim().toLowerCase();
        final filtered = applications.where((application) {
          final matchesQuery = query.isEmpty ||
              application.title.toLowerCase().contains(query) ||
              application.category.toLowerCase().contains(query) ||
              application.location.toLowerCase().contains(query);
          final matchesStatus = _statusFilter == null || application.status == _statusFilter;
          return matchesQuery && matchesStatus;
        }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                title: 'My applications',
                subtitle: 'Search applications, apply filters, and review details anytime.',
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _searchController,
                      label: 'Search applications',
                      prefixIcon: Icons.search,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _statusFilter == null,
                            onSelected: (_) => setState(() => _statusFilter = null),
                          ),
                          ...AppStatus.values.map(
                            (status) => ChoiceChip(
                              label: Text(status.label),
                              selected: _statusFilter == status,
                              onSelected: (_) => setState(() => _statusFilter = status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (filtered.isEmpty)
                const AppEmptyState(
                  icon: Icons.folder_open_outlined,
                  title: 'No applications found',
                  message: 'Try another search term or clear the filter chips to see all submissions.',
                )
              else
                Column(
                  children: filtered
                      .map(
                        (application) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ApplicationTile(
                            application: application,
                            onTap: () => _showApplicationDialog(context, application),
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
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({required this.application, required this.onTap});

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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              AppBadge.status(application.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            application.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppBadge.priority(application.priority),
              _Chip(icon: Icons.category_outlined, label: application.category),
              _Chip(icon: Icons.place_outlined, label: application.location),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Updated ${DateFormat('dd MMM yyyy, hh:mm a').format(application.updatedAt)}',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Chip(
      avatar: Icon(icon, size: 16, color: colors.textSecondary),
      label: Text(label),
      backgroundColor: colors.surfaceSoft,
      side: BorderSide(color: colors.border),
    );
  }
}

Future<void> _showApplicationDialog(BuildContext context, ApplicationRecord application) {
  return showDialog<void>(
    context: context,
    builder: (context) {
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
                      child: Text(application.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AppBadge.priority(application.priority),
                    AppBadge.status(application.status),
                    _dialogChip(context, application.category),
                    _dialogChip(context, application.location),
                  ],
                ),
                const SizedBox(height: 18),
                Text(application.description, style: const TextStyle(height: 1.6)),
                const SizedBox(height: 18),
                if (application.imageUrl != null && application.imageUrl!.startsWith('http'))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(application.imageUrl!, fit: BoxFit.cover),
                  )
                else
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            application.imageUrl == null ? 'No attachment uploaded' : 'Attachment: ${application.imageUrl}',
                          ),
                        ),
                      ],
                    ),
                  ),
                if (application.remarks != null && application.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Officer remarks', style: TextStyle(fontWeight: FontWeight.w800)),
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

Widget _dialogChip(BuildContext context, String label) {
  final colors = AppColors.of(context);
  return Chip(
    label: Text(label),
    backgroundColor: colors.surfaceSoft,
    side: BorderSide(color: colors.border),
  );
}
