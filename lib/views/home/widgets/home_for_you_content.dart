import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../controllers/recommendation_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cards/destination_recommendation_card.dart';
import '../../../core/widgets/states/loading_view.dart';
import 'profile_summary_card.dart';

/// Scrollable content for the "Para Ti" tab, showing personalized recommendations.
class HomeForYouContent extends StatelessWidget {
  const HomeForYouContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecommendationController>();
    final userName = context.watch<AuthController>().currentUser?.fullName ?? 'Viajero';

    if (controller.isLoading) {
      return const LoadingView();
    }

    if (controller.recommendations.isEmpty) {
      return _emptyState(controller.error);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // ── Profile Summary Card ──
          ProfileSummaryCard(userName: userName),

          const SizedBox(height: 32),

          // ── Section Title ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recomendados para ti',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${controller.recommendations.length} lugares seleccionados',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Recommendation cards ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: controller.recommendations.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final rec = entry.value;
                  return DestinationRecommendationCard(
                    recommendation: rec,
                    index: index,
                    onTap: () => context.push('/destination/${rec.destination.id}'),
                  );
                },
              ).toList(),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _emptyState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: error != null ? Colors.red.withValues(alpha: 0.1) : AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                error != null ? Icons.error_outline_rounded : Icons.auto_awesome_rounded,
                color: error != null ? Colors.red : AppColors.accent,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              error != null ? 'Algo salió mal' : 'Personalizando tu experiencia',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Completa tu perfil de viajero para\nrecibir recomendaciones a tu medida.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
