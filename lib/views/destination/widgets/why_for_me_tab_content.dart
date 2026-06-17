import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/aspect_score_model.dart';
import '../../../models/traveler_profile_model.dart';
import 'ranking_header_card.dart';
import 'metric_circle_indicator.dart';
import 'aspect_score_grid.dart';
import 'traveler_profile_summary_card.dart';

/// Full content for the "¿Por qué para mí?" tab in the destination detail.
/// Assembles all sub-sections based on the prototype design.
class WhyForMeTabContent extends StatelessWidget {
  final int? rankPosition;
  final int compatibilityPercentage;
  final String label;
  final String explanation;
  final List<AspectScoreModel> aspectScores;
  final TravelerProfileModel? travelerProfile;
  final String destinationClimate;
  final String destinationCrowdLevel;

  const WhyForMeTabContent({
    super.key,
    this.rankPosition,
    required this.compatibilityPercentage,
    required this.label,
    required this.explanation,
    required this.aspectScores,
    this.travelerProfile,
    required this.destinationClimate,
    required this.destinationCrowdLevel,
  });

  @override
  Widget build(BuildContext context) {
    // Derive metrics from aspect scores
    final affinityScore = _calculateAffinity();
    final climateScore = _findAspectScore('Clima');
    final crowdScore = _findAspectScore('Aforo');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══ 1. Ranking Header Card ═══
        RankingHeaderCard(
          rankPosition: rankPosition,
          compatibilityPercentage: compatibilityPercentage,
          label: label,
        ),

        const SizedBox(height: 16),

        // Removed fake summary line

        // ═══ 3. ¿Por qué se recomienda? ═══
        if (explanation.isNotEmpty) ...[
          _buildSectionTitle('¿Por qué se recomienda?'),
          const SizedBox(height: 10),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          // ═══ 4. Three metric circles ═══
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MetricCircleIndicator(
                  label: 'Afinidad base',
                  percentage: affinityScore,
                  icon: Icons.favorite_rounded,
                  color: AppColors.accent,
                ),
                MetricCircleIndicator(
                  label: 'Clima favorable',
                  percentage: climateScore,
                  icon: Icons.wb_sunny_rounded,
                  color: AppColors.accent,
                ),
                MetricCircleIndicator(
                  label: 'Aforo moderado',
                  percentage: crowdScore,
                  icon: Icons.groups_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),

        // ═══ 5. Factores que más influyen ═══
        _buildSectionTitle('Factores que más influyen'),
        const SizedBox(height: 14),
        const Text(
          'Aún no hay suficientes datos para explicar este destino con detalle.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: 28),

        // ═══ 6. Aspectos turísticos evaluados ═══
        if (aspectScores.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: _buildSectionTitle('Aspectos turísticos evaluados'),
              ),
              GestureDetector(
                onTap: () {
                  // Could show info dialog about ABSA
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textMuted, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: AspectScoreGrid(aspects: aspectScores),
          ),
        ],

        const SizedBox(height: 28),

        // ═══ 7. Tu perfil de viajero (resumen) ═══
        TravelerProfileSummaryCard(profile: travelerProfile),

        const SizedBox(height: 20),

        // ═══ 8. Footer: model info ═══
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Modelo usado: WSM + similitud de perfil + re-ranking contextual',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 9,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Calculate overall affinity from the average of all aspect scores.
  int _calculateAffinity() {
    if (aspectScores.isEmpty) return 0;
    final avg =
        aspectScores.map((a) => a.score).reduce((a, b) => a + b) /
        aspectScores.length;
    return (avg * 100).round().clamp(0, 100);
  }

  /// Find a specific aspect's score by keyword.
  int? _findAspectScore(String keyword) {
    final lower = keyword.toLowerCase();
    for (final a in aspectScores) {
      if (a.aspect.toLowerCase().contains(lower)) {
        return (a.score * 100).round().clamp(0, 100);
      }
    }
    return null; // No fallback
  }
}
