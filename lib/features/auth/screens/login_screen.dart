import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../shared/models/app_role.dart';
import '../services/auth_controller.dart';

enum AuthScreenMode { login, signUp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.initialMode});

  final AuthScreenMode initialMode;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AuthScreenMode _mode;
  AppRole _role = AppRole.user;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final auth = context.read<AuthController>();
    try {
      if (_mode == AuthScreenMode.login) {
        await auth.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await auth.signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _role,
        );
      }

      if (!mounted) {
        return;
      }

      context.go(auth.role?.routeBase ?? '/loading');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('StateError: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final auth = context.watch<AuthController>();
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 980;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                children: [
                  if (isWide)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: _HeroPanel(mode: _mode),
                      ),
                    ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: AppCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primary, AppColors.accent],
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
                                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Fire NOC application management',
                                          style: TextStyle(color: colors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SegmentedButton<AuthScreenMode>(
                                segments: const [
                                  ButtonSegment(
                                    value: AuthScreenMode.login,
                                    label: Text('Login'),
                                    icon: Icon(Icons.login_rounded),
                                  ),
                                  ButtonSegment(
                                    value: AuthScreenMode.signUp,
                                    label: Text('Sign up'),
                                    icon: Icon(Icons.person_add_alt_1_rounded),
                                  ),
                                ],
                                selected: {_mode},
                                onSelectionChanged: (values) {
                                  setState(() => _mode = values.first);
                                },
                              ),
                              const SizedBox(height: 22),
                              if (_mode == AuthScreenMode.signUp) ...[
                                AppTextField(
                                  controller: _nameController,
                                  label: 'Full name',
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter your name' : null,
                                ),
                                const SizedBox(height: 16),
                              ],
                              AppTextField(
                                controller: _emailController,
                                label: 'Email address',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Enter your email';
                                  }
                                  if (!text.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _passwordController,
                                label: 'Password',
                                obscureText: true,
                                prefixIcon: Icons.lock_outline,
                                validator: (value) {
                                  if ((value ?? '').length < 6) {
                                    return 'Use at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              if (_mode == AuthScreenMode.signUp) ...[
                                const SizedBox(height: 16),
                                DropdownButtonFormField<AppRole>(
                                    initialValue: _role,
                                  decoration: const InputDecoration(
                                    labelText: 'Role',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  items: AppRole.values
                                      .map(
                                        (role) => DropdownMenuItem(
                                          value: role,
                                          child: Text(role.label),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _role = value);
                                    }
                                  },
                                ),
                              ],
                              const SizedBox(height: 24),
                              AppButton(
                                label: auth.isBusy
                                    ? 'Please wait...'
                                    : _mode == AuthScreenMode.login
                                        ? 'Login'
                                        : 'Create account',
                                icon: _mode == AuthScreenMode.login
                                    ? Icons.login_rounded
                                    : Icons.verified_user_outlined,
                                onPressed: auth.isBusy ? null : _submit,
                                expanded: true,
                              ),
                              const SizedBox(height: 14),
                              const AppEmptyState(
                                icon: Icons.security_rounded,
                                title: 'Role based access',
                                message:
                                    'Users can only see their own applications, while officers review all submissions with realtime updates.',
                              ),
                              if (auth.isDemoMode) ...[
                                const SizedBox(height: 16),
                                AppBadge(
                                  label: 'Local demo mode enabled',
                                  color: colors.accent,
                                  icon: Icons.info_outline,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.mode});

  final AuthScreenMode mode;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Container(
        constraints: const BoxConstraints(minHeight: 640),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 48),
                SizedBox(height: 24),
                Text(
                  'Fire NOC operations that feel enterprise-ready.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'SmartNOC keeps user applications, officer reviews, status changes, and notifications in one responsive SaaS dashboard.',
                  style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroBullet(icon: Icons.auto_awesome_rounded, text: 'AI-assisted priority detection'),
                _HeroBullet(icon: Icons.sync_rounded, text: 'Realtime status notifications'),
                _HeroBullet(icon: Icons.verified_user_rounded, text: 'Role-based dashboards and route guards'),
                const SizedBox(height: 24),
                Text(
                  mode == AuthScreenMode.login
                      ? 'Use your account to continue.'
                      : 'Create a user or officer account in one pass.',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBullet extends StatelessWidget {
  const _HeroBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
