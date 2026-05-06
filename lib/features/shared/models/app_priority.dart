import 'package:flutter/material.dart';

enum AppPriority { high, medium, low }

extension AppPriorityX on AppPriority {
  String get label => switch (this) {
        AppPriority.high => 'High',
        AppPriority.medium => 'Medium',
        AppPriority.low => 'Low',
      };

  Color get color => switch (this) {
        AppPriority.high => const Color(0xFFDC2626),
        AppPriority.medium => const Color(0xFFF97316),
        AppPriority.low => const Color(0xFF16A34A),
      };

  static AppPriority fromString(String value) {
    return switch (value.toLowerCase()) {
      'high' => AppPriority.high,
      'medium' => AppPriority.medium,
      _ => AppPriority.low,
    };
  }
}
