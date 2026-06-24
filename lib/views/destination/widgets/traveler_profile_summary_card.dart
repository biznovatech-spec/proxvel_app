import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/traveler_profile_model.dart';

/// Bottom card showing a summary of the user's traveler profile with
/// key preferences as chips and a link to edit.
class TravelerProfileSummaryCard extends StatelessWidget {
  final TravelerProfileModel? profile;

  const TravelerProfileSummaryCard({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final prefs = _extractPreferences(profile);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (sin acción de editar — la edición vive en el perfil)
          const Text(
            'Tu perfil de viajero (resumen)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 14),

          // Preference chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prefs.map((pref) => _preferenceChip(
              pref['icon'] as IconData,
              pref['label'] as String,
              pref['value'] as String,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _preferenceChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _extractPreferences(TravelerProfileModel? profile) {
    if (profile == null) {
      return [
        {'icon': Icons.wb_sunny_outlined, 'label': 'Prefiere clima', 'value': 'Templado'},
        {'icon': Icons.groups_outlined, 'label': 'Tolerancia a multitudes', 'value': 'Baja'},
        {'icon': Icons.explore_outlined, 'label': 'Estilo de viaje', 'value': 'Cultural y aventura'},
      ];
    }
    return [
      {'icon': Icons.wb_sunny_outlined, 'label': 'Prefiere clima', 'value': profile.climaPreferido},
      {'icon': Icons.groups_outlined, 'label': 'Tolerancia a multitudes', 'value': profile.toleranciaMultitudes},
      {'icon': Icons.explore_outlined, 'label': 'Tipo de interés', 'value': profile.tipoInteres},
    ];
  }
}
