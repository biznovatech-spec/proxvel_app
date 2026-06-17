import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/traveler_profile_model.dart';

/// Resumen de las preferencias del viajero (presupuesto, días, clima, etc.)
/// como chips. Solo muestra datos reales del perfil.
class PreferencesSummaryCard extends StatelessWidget {
  final TravelerProfileModel profile;

  const PreferencesSummaryCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tus preferencias',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PrefChip(emoji: '💰', label: profile.presupuesto),
                _PrefChip(
                  emoji: '📅',
                  label: profile.diasViaje >= 7
                      ? '7+ días'
                      : '${profile.diasViaje} días',
                ),
                _PrefChip(emoji: '🌤️', label: profile.climaPreferido),
                _PrefChip(
                  emoji: '👥',
                  label: 'Multitud: ${profile.toleranciaMultitudes}',
                ),
                ...profile.intereses
                    .take(4)
                    .map((i) => _PrefChip(emoji: '🏷️', label: i)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrefChip extends StatelessWidget {
  final String emoji;
  final String label;

  const _PrefChip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
