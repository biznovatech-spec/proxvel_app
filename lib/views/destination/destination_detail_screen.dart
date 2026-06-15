import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/destination_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/traveler_profile_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/images/adaptive_destination_image.dart';
import '../../core/widgets/states/loading_view.dart';
import 'widgets/why_for_me_tab_content.dart';
import 'widgets/about_destination_tab_content.dart';
import 'widgets/reviews_tab_content.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;
  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DestinationController>().loadDestination(
        widget.destinationId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

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
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    () => favCtrl.toggleFavorite(dest.id),
                    iconColor: isFav ? AppColors.error : Colors.black,
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AdaptiveDestinationImage(imagePath: dest.imageUrl),
                      // Gradient overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0x20000000),
                              Color(0xCC000000),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // Title & Location
                      Positioned(
                        left: 20,
                        bottom: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dest.name,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.accent,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${dest.city}, ${dest.region}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
              ),

              // ═══ BODY ═══
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Info badges ──
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _infoBadge(Icons.category_outlined, dest.category),
                          if (controller.averageRating > 0)
                            _infoBadge(
                              Icons.star_rounded,
                              '${controller.averageRating.toStringAsFixed(1)} según opiniones',
                            )
                          else if (dest.rating > 0)
                            _infoBadge(
                              Icons.star_rounded,
                              '${dest.rating.toStringAsFixed(1)} según opiniones',
                            )
                          else
                            _infoBadge(
                              Icons.star_border_rounded,
                              'Nuevo',
                            ),
                          if (dest.estimatedDays != null)
                            _infoBadge(
                              Icons.schedule_rounded,
                              dest.estimatedDays!,
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Tab selector ──
                      _buildTabSelector(),

                      const SizedBox(height: 20),

                      // ── Divider ──
                      Container(height: 1, color: AppColors.border),

                      const SizedBox(height: 24),

                      // ── Tab content ──
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _selectedTabIndex == 0
                            ? _buildWhyForMeContent(controller)
                            : _selectedTabIndex == 1
                                ? _buildAboutDestinationContent(controller)
                                : ReviewsTabContent(key: const ValueKey('reviews'), controller: controller),
                      ),
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

  Widget _buildTabSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _tabItem('¿Por qué para mí?', 0)),
          Expanded(child: _tabItem('Sobre el destino', 1)),
          Expanded(child: _tabItem('Opiniones', 2)),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    final isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              color: isActive ? AppColors.accent : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: isActive ? 0 : 30),
            decoration: BoxDecoration(
              color: isActive ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 0: ¿Por qué para mí? ──
  Widget _buildWhyForMeContent(DestinationController controller) {
    final dest = controller.destination!;

    // Try to get traveler profile if ProfileController is available
    TravelerProfileModel? travelerProfile;
    try {
      travelerProfile = context.read<ProfileController>().profile;
    } catch (_) {
      // ProfileController might not be in the tree
    }

    // Determine rank position from recommendations context
    // Default to 1 since we don't have the list index here
    final rankPosition = 1;

    return WhyForMeTabContent(
      key: const ValueKey('why_for_me'),
      rankPosition: rankPosition,
      compatibilityPercentage: controller.compatibility,
      label: controller.compatibility >= 85
          ? 'Recomendado'
          : controller.compatibility >= 70
          ? 'Parcialmente rec.'
          : 'Por explorar',
      explanation: controller.explanation,
      aspectScores: controller.aspectScores,
      travelerProfile: travelerProfile,
      destinationClimate: dest.climate,
      destinationCrowdLevel: dest.crowdLevel,
    );
  }

  // ── Tab 1: Sobre el destino ──
  Widget _buildAboutDestinationContent(DestinationController controller) {
    final dest = controller.destination!;
    return AboutDestinationTabContent(
      key: const ValueKey('about_destination'),
      destination: dest,
      tourismInfo: controller.tourismInfo,
    );
  }

  // ── Circle icon button (back, fav) ──
  Widget _circleButton(
    IconData icon,
    VoidCallback onTap, {
    Color iconColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
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
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  context.read<FavoritesController>().toggleFavorite(destId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: context.watch<FavoritesController>().isFavorite(destId)
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  border: context.watch<FavoritesController>().isFavorite(destId)
                      ? Border.all(color: AppColors.error.withValues(alpha: 0.5))
                      : null,
                  boxShadow: context.watch<FavoritesController>().isFavorite(destId)
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      context.watch<FavoritesController>().isFavorite(destId)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: context.watch<FavoritesController>().isFavorite(destId)
                          ? AppColors.error
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.watch<FavoritesController>().isFavorite(destId)
                          ? 'En favoritos'
                          : 'Añadir a favoritos',
                      style: TextStyle(
                        color: context.watch<FavoritesController>().isFavorite(destId)
                            ? AppColors.error
                            : Colors.white,
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
