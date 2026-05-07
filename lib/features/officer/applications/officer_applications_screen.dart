import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../features/shared/models/app_priority.dart';
import '../../../features/shared/models/app_status.dart';
import '../../../features/shared/models/application_record.dart';
import '../../../features/shared/services/noc_repository.dart';

class OfficerApplicationsScreen extends StatefulWidget {
  const OfficerApplicationsScreen({super.key});

  @override
  State<OfficerApplicationsScreen> createState() => _OfficerApplicationsScreenState();
}

class _OfficerApplicationsScreenState extends State<OfficerApplicationsScreen> {
  final _searchController = TextEditingController();
  AppStatus? _statusFilter;
  AppPriority? _priorityFilter;
  String? _categoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<NocRepository>();

    return StreamBuilder<List<ApplicationRecord>>(
      stream: repository.watchAllApplications(),
      builder: (context, snapshot) {
        final applications = snapshot.data ?? const <ApplicationRecord>[];
        final query = _searchController.text.trim().toLowerCase();
        final categories = applications.map((item) => item.category).where((item) => item.isNotEmpty).toSet().toList()..sort();
        final filtered = applications.where((application) {
          final matchesQuery = query.isEmpty ||
              application.title.toLowerCase().contains(query) ||
              application.category.toLowerCase().contains(query) ||
              application.location.toLowerCase().contains(query) ||
              application.applicantName.toLowerCase().contains(query);
          final matchesStatus = _statusFilter == null || application.status == _statusFilter;
          final matchesPriority = _priorityFilter == null || application.priority == _priorityFilter;
          final matchesCategory = _categoryFilter == null || application.category == _categoryFilter;
          return matchesQuery && matchesStatus && matchesPriority && matchesCategory;
        }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _searchController,
                      label: 'Search by title, category, applicant, or location',
                      prefixIcon: Icons.search,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 860;
                        final filterRow = Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ChoiceChip(
                              label: const Text('All status'),
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
                            ChoiceChip(
                              label: const Text('All priority'),
                              selected: _priorityFilter == null,
                              onSelected: (_) => setState(() => _priorityFilter = null),
                            ),
                            ...AppPriority.values.map(
                              (priority) => ChoiceChip(
                                label: Text(priority.label),
                                selected: _priorityFilter == priority,
                                onSelected: (_) => setState(() => _priorityFilter = priority),
                              ),
                            ),
                          ],
                        );

                        final categoryDropdown = DropdownButtonFormField<String?>(
                          initialValue: _categoryFilter,
                          decoration: const InputDecoration(labelText: 'Category filter'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All categories')),
                            ...categories.map((category) => DropdownMenuItem(value: category, child: Text(category))),
                          ],
                          onChanged: (value) => setState(() => _categoryFilter = value),
                        );

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: filterRow),
                              const SizedBox(width: 16),
                              SizedBox(width: 260, child: categoryDropdown),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            filterRow,
                            const SizedBox(height: 14),
                            categoryDropdown,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (filtered.isEmpty)
                const AppEmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'No matching applications',
                  message: 'Adjust the filters or search terms to broaden the result set.',
                )
              else
                Column(
                  children: filtered
                      .map(
                        (application) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: AppCard(
                            onTap: () => context.go('/officer/review/${application.id}'),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      const SizedBox(height: 4),
                                      Text(
                                        '${application.applicantName} • ${application.location}',
                                        style: const TextStyle(color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        application.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(height: 1.5),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: [
                                          AppBadge.status(application.status),
                                          _chip(application.category),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right_rounded),
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
  }
}

Widget _chip(String label) {
  return Chip(
    label: Text(label),
    backgroundColor: AppColors.surfaceSoft,
    side: const BorderSide(color: AppColors.border),
  );
}
