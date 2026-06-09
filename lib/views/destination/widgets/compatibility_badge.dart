import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Circular badge showing compatibility percentage.
class CompatibilityBadge extends StatelessWidget {
  final int percentage;

  const CompatibilityBadge({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final color = _colorForPct(percentage);

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.6),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const Text(
              'match',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForPct(int pct) {
    if (pct >= 85) return AppColors.success;
    if (pct >= 70) return AppColors.accent;
    return AppColors.textSecondary;
  }
}
