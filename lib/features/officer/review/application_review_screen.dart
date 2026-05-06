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
import '../../../core/widgets/app_text_field.dart';
import '../../../features/shared/models/app_status.dart';
import '../../../features/shared/models/application_record.dart';
import '../../../features/shared/models/app_user_profile.dart';
import '../../../features/shared/services/noc_repository.dart';

class ApplicationReviewScreen extends StatefulWidget {
  const ApplicationReviewScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  State<ApplicationReviewScreen> createState() => _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  final _remarksController = TextEditingController();
  AppStatus _selectedStatus = AppStatus.underReview;
  bool _saving = false;
  String? _loadedApplicationId;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(NocRepository repository, ApplicationRecord application, AppStatus status) async {
    setState(() {
      _saving = true;
      _selectedStatus = status;
    });
    try {
      await repository.updateApplicationStatus(
        applicationId: application.id,
        status: status,
        remarks: _remarksController.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${application.title} marked ${status.label}')),
      );
      if (context.mounted) {
        context.go('/officer/applications');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('StateError: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<NocRepository>();

    return FutureBuilder<ApplicationRecord?>(
      future: repository.getApplicationById(widget.applicationId),
      builder: (context, snapshot) {
        final application = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (application == null) {
          return const AppEmptyState(
            icon: Icons.find_in_page_outlined,
            title: 'Application not found',
            message: 'The selected application may have been removed or is unavailable.',
          );
        }

        if (_loadedApplicationId != application.id) {
          _loadedApplicationId = application.id;
          _selectedStatus = application.status;
          _remarksController.text = application.remarks ?? '';
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionHeader(
                title: application.title,
                subtitle: 'Review the applicant, uploaded files, and processing history before taking action.',
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 980;
                  final details = _DetailsPanel(application: application, repository: repository);
                  final actions = _ActionsPanel(
                    application: application,
                    selectedStatus: _selectedStatus,
                    remarksController: _remarksController,
                    saving: _saving,
                    onStatusChanged: (status) => setState(() => _selectedStatus = status),
                    onAction: (status) => _updateStatus(repository, application, status),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: details),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: actions),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      details,
                      const SizedBox(height: 16),
                      actions,
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.application, required this.repository});

  final ApplicationRecord application;
  final NocRepository repository;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 20),
          FutureBuilder<AppUserProfile?>(
            future: repository.getProfileById(application.userId),
            builder: (context, profileSnapshot) {
              final applicant = profileSnapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Applicant', applicant?.name ?? application.applicantName),
                  _infoRow('Email', applicant?.email ?? application.applicantEmail),
                  _infoRow('Submitted', DateFormat('dd MMM yyyy, hh:mm a').format(application.createdAt)),
                  _infoRow('Last updated', DateFormat('dd MMM yyyy, hh:mm a').format(application.updatedAt)),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 10),
          Text(application.description, style: const TextStyle(height: 1.6)),
          const SizedBox(height: 20),
          const Text('Attachment preview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 10),
          if (application.imageUrl != null && application.imageUrl!.startsWith('http'))
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(application.imageUrl!, fit: BoxFit.cover),
            )
          else
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      application.imageUrl == null ? 'No attachment uploaded' : application.imageUrl!,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ActionsPanel extends StatelessWidget {
  const _ActionsPanel({
    required this.application,
    required this.selectedStatus,
    required this.remarksController,
    required this.saving,
    required this.onStatusChanged,
    required this.onAction,
  });

  final ApplicationRecord application;
  final AppStatus selectedStatus;
  final TextEditingController remarksController;
  final bool saving;
  final ValueChanged<AppStatus> onStatusChanged;
  final ValueChanged<AppStatus> onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Officer actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          DropdownButtonFormField<AppStatus>(
            initialValue: selectedStatus,
            decoration: const InputDecoration(labelText: 'Status'),
            items: AppStatus.values
                .map((status) => DropdownMenuItem(value: status, child: Text(status.label)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onStatusChanged(value);
              }
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: remarksController,
            label: 'Officer remarks',
            maxLines: 6,
            prefixIcon: Icons.note_alt_outlined,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(label: 'Under Review', icon: Icons.visibility_outlined, onPressed: saving ? null : () => onAction(AppStatus.underReview)),
              AppButton(label: 'Approve', icon: Icons.verified_outlined, onPressed: saving ? null : () => onAction(AppStatus.approved)),
              AppButton(label: 'On Hold', icon: Icons.pause_circle_outline, outlined: true, onPressed: saving ? null : () => onAction(AppStatus.onHold)),
              AppButton(label: 'Decline', icon: Icons.cancel_outlined, outlined: true, danger: true, onPressed: saving ? null : () => onAction(AppStatus.declined)),
            ],
          ),
          if (saving) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 18),
          Text(
            'Application submitted by ${application.applicantName}. Use remarks to explain the decision clearly.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
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
