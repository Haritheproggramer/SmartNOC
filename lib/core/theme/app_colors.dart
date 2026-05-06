import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette({
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.muted,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color primary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color muted;
  final Color success;
  final Color warning;
  final Color danger;
}

class AppColors {
  // Backward-compatible constants used across feature screens.
  static const Color primary = Color(0xFF1E3A8A);
  static const Color accent = Color(0xFF2563EB);
  static const Color background = Color(0xFF030B1D);
  static const Color surface = Color(0xFF08152E);
  static const Color surfaceSoft = Color(0xFF0E1F42);
  static const Color textPrimary = Color(0xFFE6ECFF);
  static const Color textSecondary = Color(0xFF8FA4C8);
  static const Color border = Color(0xFF1D335D);
  static const Color muted = Color(0xFF6E84A8);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF97316);
  static const Color danger = Color(0xFFDC2626);

  static const AppPalette light = AppPalette(
    primary: Color(0xFF1E3A8A),
    accent: Color(0xFF2563EB),
    background: Color(0xFFF8FAFC),
    surface: Colors.white,
    surfaceSoft: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    border: Color(0xFFE2E8F0),
    muted: Color(0xFF64748B),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF97316),
    danger: Color(0xFFDC2626),
  );

  static const AppPalette dark = AppPalette(
    primary: Color(0xFF1E3A8A),
    accent: Color(0xFF2F6BFF),
    background: Color(0xFF030B1D),
    surface: Color(0xFF08152E),
    surfaceSoft: Color(0xFF0E1F42),
    textPrimary: Color(0xFFE6ECFF),
    textSecondary: Color(0xFF8FA4C8),
    border: Color(0xFF1D335D),
    muted: Color(0xFF6E84A8),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF97316),
    danger: Color(0xFFDC2626),
  );

  static AppPalette of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}
