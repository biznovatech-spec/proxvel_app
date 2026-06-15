import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/explanation_model.dart';
import '../../../models/context_signal_model.dart';

class RecommendationExplanationSection extends StatelessWidget {
  final ExplanationModel? explanation;
  final List<ContextSignalModel> contextSignals;

  const RecommendationExplanationSection({
    super.key,
    this.explanation,
    required this.contextSignals,
  });

  String _translateAspect(String rawAspect) {
    const map = {
      'atractivos': 'Atractivos turísticos',
      'clima': 'Clima',
      'costos': 'Costos',
      'gastronomia': 'Gastronomía',
      'seguridad': 'Seguridad',
      'limpieza': 'Limpieza',
      'accesibilidad': 'Accesibilidad',
      'atencion_servicio': 'Atención y servicio',
      'aforo_multitudes': 'Afluencia de personas',
      'alojamiento': 'Alojamiento',
    };
    return map[rawAspect.toLowerCase()] ??
        rawAspect.replaceAll('_', ' ').replaceFirstMapped(
            RegExp(r'^[a-z]'), (m) => m.group(0)!.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    if (explanation == null && contextSignals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: const Text(
          'Recomendación basada en tu perfil viajero.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Por qué te lo recomendamos:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          if (explanation?.summary != null && explanation!.summary.isNotEmpty)
            Text(
              explanation!.summary,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          
          if (explanation != null && explanation!.topAspects.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: explanation!.topAspects.map((aspect) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        _translateAspect(aspect.aspect),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          
          if (contextSignals.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primaryDark),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Contexto favorable',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 10, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                'Recomendación personalizada',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
