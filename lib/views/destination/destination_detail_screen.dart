import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/destination_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/traveler_profile_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/images/adaptive_destination_image.dart';
import '../../core/widgets/states/loading_view.dart';
import 'widgets/why_for_me_tab_content.dart';
import 'widgets/about_destination_tab_content.dart';
import 'widgets/reviews_tab_content.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;

  /// Origen de navegación: explore | search | ai_recommendation | ai_search.
  /// Define la jerarquía de pestañas (info primero vs IA primero).
  final String source;

  const DestinationDetailScreen({
    super.key,
    required this.destinationId,
    this.source = 'explore',
  });

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  int _selectedTabIndex = 0;

  /// La IA es primaria solo cuando se llega desde una recomendación IA.
  bool get _aiPrimary =>
      widget.source == 'ai_recommendation' || widget.source == 'ai_search';

  /// Orden de pestañas según el origen.
  /// - IA primaria: [IA, Sobre el destino, Opiniones]
  /// - Catálogo/Búsqueda: [Sobre el destino, Opiniones, IA] (IA al final)
  List<String> get _tabKeys =>
      _aiPrimary ? const ['ai', 'about', 'reviews'] : const ['about', 'reviews', 'ai'];

  String _tabLabel(String key) {
    switch (key) {
      case 'ai':
        return '¿Por qué para mí?';
      case 'about':
        return 'Sobre el destino';
      default:
        return 'Opiniones';
    }
  }

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
                  // Solo este botón se reconstruye al cambiar el favorito,
                  // no toda la pantalla de detalle.
                  Selector<FavoritesController, bool>(
                    selector: (_, c) => c.isFavorite(dest.id),
                    builder: (context, isFav, _) => _circleButton(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      () => context
                          .read<FavoritesController>()
                          .toggleFavorite(dest.id),
                      iconColor: isFav ? AppColors.error : Colors.black,
                    ),
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
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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

                      // ── Tab content (según el orden definido por el origen) ──
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _buildTabContent(
                          _tabKeys[_selectedTabIndex],
                          controller,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          for (int i = 0; i < _tabKeys.length; i++)
            Expanded(child: _tabItem(_tabLabel(_tabKeys[i]), i)),
        ],
      ),
    );
  }

  Widget _buildTabContent(String key, DestinationController controller) {
    switch (key) {
      case 'ai':
        return _buildWhyForMeContent(controller);
      case 'about':
        return _buildAboutDestinationContent(controller);
      default:
        return ReviewsTabContent(
            key: const ValueKey('reviews'), controller: controller);
    }
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
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.2,
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
    // We don't have the list index here, so we pass null instead of a fake rank

    return WhyForMeTabContent(
      key: const ValueKey('why_for_me'),
      rankPosition: null,
      compatibilityPercentage: controller.compatibility,
      label: controller.compatibility >= AppConstants.compatibilityRecommended
          ? 'Recomendado'
          : controller.compatibility >= AppConstants.compatibilityPartial
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
}
