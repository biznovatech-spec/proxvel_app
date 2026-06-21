import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/recommendation_result_model.dart';
import '../../../controllers/favorites_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../images/adaptive_destination_image.dart';
import '../../../views/home/widgets/recommendation_explanation_section.dart';

/// Card showing a personalized recommendation with compatibility score.
class DestinationRecommendationCard extends StatelessWidget {
  final RecommendationResultModel recommendation;
  final VoidCallback onTap;
  final int index;

  const DestinationRecommendationCard({
    super.key,
    required this.recommendation,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final dest = recommendation.destination;
    final pct = recommendation.compatibilityPercentage.round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Image Section ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AdaptiveDestinationImage(imagePath: dest.imageUrl),
                    // Dark gradient from bottom
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                    // Top-left # badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Top-right Recomendado badge
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Recomendado',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Favorite Heart
                          Consumer<FavoritesController>(
                            builder: (context, favCtrl, child) {
                              final isFav = favCtrl.isFavorite(dest.id);
                              return GestureDetector(
                                onTap: () => favCtrl.toggleFavorite(dest.id),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: isFav ? AppColors.error : Colors.white,
                                    size: 18,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Bottom content overlay
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dest.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: AppColors.accent, size: 14),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        dest.city,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    if (dest.category.isNotEmpty)
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            dest.category,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // ── Explanation Section ──
            RecommendationExplanationSection(
              explanation: recommendation.explanation,
              contextSignals: recommendation.contextSignals,
            ),
            
            // ── Footer Section ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Progress bar
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: pct / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$pct% compatible',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Ver más',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16, color: AppColors.primaryDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
