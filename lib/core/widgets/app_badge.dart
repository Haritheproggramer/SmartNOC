import 'package:flutter/material.dart';

import '../../features/shared/models/app_priority.dart';
import '../../features/shared/models/app_status.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory AppBadge.priority(AppPriority priority) {
    return AppBadge(
      label: priority.label,
      color: priority.color,
      icon: Icons.local_fire_department_outlined,
    );
  }

  factory AppBadge.status(AppStatus status) {
    return AppBadge(
      label: status.label,
      color: status.color,
      icon: switch (status) {
        AppStatus.approved => Icons.verified_outlined,
        AppStatus.declined => Icons.cancel_outlined,
        AppStatus.onHold => Icons.pause_circle_outline,
        AppStatus.underReview => Icons.visibility_outlined,
        AppStatus.pending => Icons.schedule_outlined,
      },
    );
  }

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
