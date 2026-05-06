import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../features/auth/services/auth_controller.dart';
import '../../../features/shared/models/app_priority.dart';
import '../../../features/shared/services/noc_repository.dart';
import '../../../features/shared/services/priority_service.dart';

class CreateApplicationScreen extends StatefulWidget {
  const CreateApplicationScreen({super.key});

  @override
  State<CreateApplicationScreen> createState() => _CreateApplicationScreenState();
}

class _CreateApplicationScreenState extends State<CreateApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _customCategoryController = TextEditingController();

  PlatformFile? _file;
  String _category = 'Commercial inspection';
  AppPriority _priority = AppPriority.medium;
  bool _submitting = false;

  final List<String> _categories = const [
    'Commercial inspection',
    'Restaurant',
    'School',
    'Factory',
    'Hospital',
    'ICU',
    'Renewal',
    'Routine inspection',
    'Small office',
    'Emergency',
  ];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_recalculatePriority);
    _descriptionController.addListener(_recalculatePriority);
    _customCategoryController.addListener(_recalculatePriority);
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_recalculatePriority)
      ..dispose();
    _descriptionController
      ..removeListener(_recalculatePriority)
      ..dispose();
    _locationController.dispose();
    _customCategoryController
      ..removeListener(_recalculatePriority)
      ..dispose();
    super.dispose();
  }

  void _recalculatePriority() {
    final priority = PriorityService.derivePriority(
      title: _titleController.text,
      category: _effectiveCategory,
      description: _descriptionController.text,
      location: _locationController.text,
    );
    if (priority != _priority) {
      setState(() => _priority = priority);
    }
  }

  String get _effectiveCategory {
    final custom = _customCategoryController.text.trim();
    return custom.isEmpty ? _category : custom;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.any,
    );
    if (result == null) {
      return;
    }
    setState(() => _file = result.files.single);
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final auth = context.read<AuthController>();
    final profile = auth.currentProfile;
    if (profile == null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final repository = context.read<NocRepository>();
      final application = await repository.createApplication(
        profile: profile,
        title: _titleController.text,
        category: _effectiveCategory,
        description: _descriptionController.text,
        location: _locationController.text,
        priority: _priority,
        attachment: _file,
      );
      if (!mounted) {
        return;
      }
      _formKey.currentState?.reset();
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _customCategoryController.clear();
      setState(() {
        _category = 'Commercial inspection';
        _priority = application.priority;
        _file = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('StateError: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Create application',
            subtitle: 'Submit a new fire NOC request with automatic priority detection.',
          ),
          const SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 860;
                          final fields = Column(
                            children: [
                              AppTextField(
                                controller: _titleController,
                                label: 'Title',
                                prefixIcon: Icons.title_rounded,
                                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter a title' : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: _category,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon: Icon(Icons.category_outlined),
                                ),
                                items: _categories
                                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _category = value);
                                    _recalculatePriority();
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _customCategoryController,
                                label: 'Optional custom category',
                                prefixIcon: Icons.edit_outlined,
                                hint: 'Leave blank to use the selected category',
                                onChanged: (_) => _recalculatePriority(),
                              ),
                            ],
                          );

                          final rightColumn = Column(
                            children: [
                              AppTextField(
                                controller: _locationController,
                                label: 'Location',
                                prefixIcon: Icons.place_outlined,
                                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter a location' : null,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _descriptionController,
                                label: 'Description',
                                prefixIcon: Icons.notes_outlined,
                                maxLines: 5,
                                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter a description' : null,
                              ),
                            ],
                          );

                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: fields),
                                const SizedBox(width: 16),
                                Expanded(child: rightColumn),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              fields,
                              const SizedBox(height: 16),
                              rightColumn,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: _priority.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.local_fire_department_outlined, color: _priority.color),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Auto generated priority', style: TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'The system evaluates the title, category, description, and location.',
                                    style: const TextStyle(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            AppBadge.priority(_priority),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: _file == null ? 'Upload image / document' : 'Change file',
                              icon: Icons.upload_file_outlined,
                              outlined: true,
                              onPressed: _pickFile,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: AppButton(
                              label: _submitting ? 'Submitting...' : 'Submit application',
                              icon: Icons.send_rounded,
                              onPressed: _submitting ? null : _submit,
                            ),
                          ),
                        ],
                      ),
                      if (_file != null) ...[
                        const SizedBox(height: 14),
                        Text('Selected file: ${_file!.name}', style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
