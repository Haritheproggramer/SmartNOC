import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../services/auth_controller.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _forcedTimeout = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Safety net: if still on boot screen after 10 s, show a timeout error
    _safetyTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _forcedTimeout = true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _safetyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // ── Config-missing error screen ──────────────────────────────────────────
    if (!AppConfig.hasSupabaseConfig) {
      return _ConfigErrorScreen(colors: colors);
    }

    // ── Safety-timeout error screen ──────────────────────────────────────────
    if (_forcedTimeout) {
      return _TimeoutErrorScreen(colors: colors);
    }

    // ── Normal loading splash ────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) => Opacity(
                opacity: 0.6 + 0.4 * _pulseController.value,
                child: child,
              ),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading SmartNOC',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparing your secured workspace...',
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Config-missing error screen ────────────────────────────────────────────────
class _ConfigErrorScreen extends StatelessWidget {
  const _ConfigErrorScreen({required this.colors});
  final AppPalette colors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Configuration Missing',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Supabase environment variables are not compiled into this build.\n\n'
                'Add SUPABASE_URL and SUPABASE_ANON_KEY to your Vercel project '
                'under Settings → Environment Variables, then redeploy.',
                style: TextStyle(color: colors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required build variables:',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _EnvRow(
                      name: 'SUPABASE_URL',
                      example: 'https://xxxx.supabase.co',
                    ),
                    const SizedBox(height: 4),
                    _EnvRow(
                      name: 'SUPABASE_ANON_KEY',
                      example: 'eyJhbGci...',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnvRow extends StatelessWidget {
  const _EnvRow({required this.name, required this.example});
  final String name;
  final String example;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            name,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            example,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Timeout error screen ────────────────────────────────────────────────────────
class _TimeoutErrorScreen extends StatelessWidget {
  const _TimeoutErrorScreen({required this.colors});
  final AppPalette colors;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Connection Timeout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to connect to SmartNOC servers.\n'
                'Please check your internet connection and try again.',
                style: TextStyle(color: colors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              if (auth.bootError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    auth.bootError!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  // Retry: re-create the auth controller bootstrap
                  // For now navigate to /login as a fallback
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
