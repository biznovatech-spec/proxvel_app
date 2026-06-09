import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/destination_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/states/loading_view.dart';
import 'widgets/aspect_score_bar.dart';
import 'widgets/explanation_card.dart';
import 'widgets/compatibility_badge.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;
  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DestinationController>()
          .loadDestination(widget.destinationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final controller = context.watch<DestinationController>();
    final dest = controller.destination;

    if (controller.isLoading || dest == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const LoadingView(),
      );
    }

    final favCtrl = context.watch<FavoritesController>();
    final isFav = favCtrl.isFavorite(dest.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Scrollable content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ═══ HERO IMAGE ═══
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: _circleButton(
                  Icons.arrow_back_rounded,
                  () => context.pop(),
                ),
                actions: [
                  _circleButton(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    () => favCtrl.toggleFavorite(dest.id),
                    iconColor: isFav ? AppColors.error : Colors.white,
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(dest.imageUrl, fit: BoxFit.cover),
                      // Gradient overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Color(0x80000000),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // Compatibility badge
                      if (controller.compatibility > 0)
                        Positioned(
                          right: 20,
                          bottom: 20,
                          child: CompatibilityBadge(
                            percentage: controller.compatibility,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ═══ BODY ═══
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title & location ──
                      Text(
                        dest.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.accent, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${dest.city}, ${dest.region}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ── Info badges ──
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _infoBadge(Icons.category_outlined, dest.category),
                          _infoBadge(Icons.star_rounded,
                              '${dest.rating.toStringAsFixed(1)} rating'),
                          _infoBadge(Icons.attach_money_rounded,
                              'S/ ${dest.averageCost.toStringAsFixed(0)}'),
                          _infoBadge(Icons.wb_sunny_outlined, dest.climate),
                          _infoBadge(
                              Icons.groups_outlined, dest.crowdLevel),
                          if (dest.estimatedDays != null)
                            _infoBadge(
                                Icons.schedule_rounded, dest.estimatedDays!),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Description ──
                      _sectionTitle('Descripción'),
                      const SizedBox(height: 10),
                      Text(
                        dest.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Explanation ──
                      if (controller.explanation.isNotEmpty)
                        ExplanationCard(explanation: controller.explanation),

                      const SizedBox(height: 28),

                      // ── Aspect scores ──
                      if (controller.aspectScores.isNotEmpty) ...[
                        _sectionTitle('Aspectos turísticos evaluados'),
                        const SizedBox(height: 6),
                        Text(
                          'Evaluación basada en análisis de sentimiento (ABSA)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: AppColors.border, width: 1),
                          ),
                          child: Column(
                            children: controller.aspectScores
                                .map((a) => AspectScoreBar(aspect: a))
                                .toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ── Aspect chips (from destination model) ──
                      if (dest.aspects.isNotEmpty) ...[
                        _sectionTitle('Categorías destacadas'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: dest.aspects
                              .map((a) => _aspectChip(a))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom action bar ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(dest.id),
          ),
        ],
      ),
    );
  }

  // ── Circle icon button (back, fav) ──
  Widget _circleButton(IconData icon, VoidCallback onTap,
      {Color iconColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }

  // ── Info badge ──
  Widget _infoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section title ──
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ── Aspect chip ──
  Widget _aspectChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ── Bottom action bar ──
  Widget _buildBottomBar(String destId) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Favorite toggle
          GestureDetector(
            onTap: () =>
                context.read<FavoritesController>().toggleFavorite(destId),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                context.watch<FavoritesController>().isFavorite(destId)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: context.watch<FavoritesController>().isFavorite(destId)
                    ? AppColors.error
                    : AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Feedback button
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/feedback/$destId'),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rate_review_rounded,
                        color: AppColors.accent, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Enviar feedback',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
