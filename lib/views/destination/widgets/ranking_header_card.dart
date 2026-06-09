import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Card displaying the recommendation ranking position, compatibility
/// percentage, and recommendation label.
class RankingHeaderCard extends StatelessWidget {
  final int rankPosition;
  final int compatibilityPercentage;
  final String label; // 'Recomendado', 'Parcialmente recomendado', etc.

  const RankingHeaderCard({
    super.key,
    required this.rankPosition,
    required this.compatibilityPercentage,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isRecommended = label.toLowerCase().contains('recomendado') &&
        !label.toLowerCase().contains('no recomendado');
    final badgeColor = isRecommended ? AppColors.accent : AppColors.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Left: Rank badge + label ──
          Expanded(
            child: Row(
              children: [
                // Rank number badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '#$rankPosition',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // "Recomendado para ti" text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recomendado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'para ti',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Right: Compatibility % + badge ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$compatibilityPercentage%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: badgeColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'compatible contigo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              // Badge label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.length > 18
                          ? label.substring(0, 18)
                          : label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
