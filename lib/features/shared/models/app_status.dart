import 'package:flutter/material.dart';

enum AppStatus { pending, underReview, approved, declined, onHold }

extension AppStatusX on AppStatus {
  String get label => switch (this) {
        AppStatus.pending => 'Pending',
        AppStatus.underReview => 'Under Review',
        AppStatus.approved => 'Approved',
        AppStatus.declined => 'Declined',
        AppStatus.onHold => 'On Hold',
      };

  Color get color => switch (this) {
        AppStatus.pending => const Color(0xFF2563EB),
        AppStatus.underReview => const Color(0xFFF59E0B),
        AppStatus.approved => const Color(0xFF16A34A),
        AppStatus.declined => const Color(0xFFDC2626),
        AppStatus.onHold => const Color(0xFF64748B),
      };

  static AppStatus fromString(String value) {
    return switch (value.toLowerCase()) {
      'under review' => AppStatus.underReview,
      'approved' => AppStatus.approved,
      'declined' => AppStatus.declined,
      'on hold' => AppStatus.onHold,
      _ => AppStatus.pending,
    };
  }
}
