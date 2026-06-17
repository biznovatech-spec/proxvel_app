import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../controllers/recommendation_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cards/destination_recommendation_card.dart';
import '../../../core/widgets/states/loading_view.dart';
import '../../../core/widgets/states/empty_profile_for_ai_state.dart';
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
      final err = controller.error;
      // Caso perfil incompleto (o sin error): empty state honesto con acción.
      final isProfileIssue = err == null || err.toLowerCase().contains('perfil');
      if (isProfileIssue) {
        return const EmptyProfileForAiState();
      }
      return _errorState(err);
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
                  'Recomendaciones IA',
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
                    onTap: () => context.push(
                        '/destination/${rec.destination.id}?source=ai_recommendation'),
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

  Widget _errorState(String error) {
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
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Algo salió mal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
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
