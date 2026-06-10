import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cards/trending_destination_card.dart';
import '../../../core/widgets/cards/destination_card.dart';
import '../../../core/widgets/cards/recent_search_chip.dart';
import '../../../core/widgets/images/adaptive_destination_image.dart';
import '../../../core/widgets/states/loading_view.dart';

/// Scrollable content for the "Explorar" tab.
class HomeExploreContent extends StatefulWidget {
  final VoidCallback onSwitchToForYou;

  const HomeExploreContent({super.key, required this.onSwitchToForYou});

  @override
  State<HomeExploreContent> createState() => _HomeExploreContentState();
}

class _HomeExploreContentState extends State<HomeExploreContent> {
  final PageController _carouselCtrl = PageController(viewportFraction: 1.0);
  int _carouselPage = 0;
  Timer? _autoTimer;

  @override
  void dispose() {
    _autoTimer?.cancel();
    _carouselCtrl.dispose();
    super.dispose();
  }

  void _startAutoScroll(int total) {
    _autoTimer?.cancel();
    if (total <= 1) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_carouselCtrl.hasClients) return;
      final next = (_carouselPage + 1) % total;
      _carouselCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();

    if (controller.isLoading) {
      return const LoadingView();
    }

    final trending = controller.trendingDestinations;
    final nearby = controller.nearbyDestinations;
    final getaways = controller.getawayDestinations;
    final recent = controller.recentSearches;

    // Start auto-scroll when trending data is available
    if (trending.isNotEmpty && _autoTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoScroll(trending.length);
      });
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ═══════════════ SEARCH BAR ═══════════════
          _buildSearchBar(context),

          const SizedBox(height: 24),

          // ═══════════════ BÚSQUEDAS RECIENTES ═══════════════
          if (recent.isNotEmpty) ...[
            _sectionHeader('Búsquedas recientes', onSeeMore: null),
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: recent.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => RecentSearchChip(
                  destination: recent[i],
                  onTap: () => context.push('/search?q=${Uri.encodeComponent(recent[i].name)}'),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ═══════════════ LUGARES TURÍSTICOS DEL MOMENTO ═══════════════
          if (trending.isNotEmpty) ...[
            _sectionHeader('Lugares turísticos del momento', onSeeMore: () => context.push('/search')),
            const SizedBox(height: 14),
            SizedBox(
              height: 360, // Increased height for premium feel
              child: PageView.builder(
                controller: _carouselCtrl,
                itemCount: trending.length,
                onPageChanged: (i) => setState(() => _carouselPage = i),
                itemBuilder: (_, i) => TrendingDestinationCard(
                  destination: trending[i],
                  onTap: () =>
                      context.push('/destination/${trending[i].id}'),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildDots(trending.length),
            const SizedBox(height: 28),
          ],

          // ═══════════════ BANNER CTA ═══════════════
          _buildBannerCTA(),
          const SizedBox(height: 28),

          // ═══════════════ CERCA DE TI ═══════════════
          if (nearby.isNotEmpty || controller.currentLocation.isNotEmpty) ...[
            _sectionHeaderWithLocation(context, 'Cerca de ti', controller.currentLocation, (newCity) {
              controller.changeLocation(newCity);
            }),
            const SizedBox(height: 14),
            if (nearby.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text('No hay destinos cercanos encontrados en esta ubicación.', style: TextStyle(color: AppColors.textSecondary)),
              )
            else
              SizedBox(
                height: 200,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: nearby.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) => DestinationCard(
                  destination: nearby[i],
                  onTap: () =>
                      context.push('/destination/${nearby[i].id}'),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ═══════════════ ESCAPADAS SEGÚN TU TIEMPO ═══════════════
          if (getaways.isNotEmpty) ...[
            _sectionHeader('Escapadas según tu tiempo', onSeeMore: () {}),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: getaways
                    .take(5)
                    .map((d) => _buildGetawayTile(context, d))
                    .toList(),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Search Bar ──
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: AppColors.accent, size: 22),
                    const SizedBox(width: 12),
                    const Text(
                      '¿A dónde viajas hoy?',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/search'),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.textOnDark, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ──
  Widget _sectionHeader(String title, {VoidCallback? onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (onSeeMore != null)
            GestureDetector(
              onTap: onSeeMore,
              child: const Text(
                'Ver más',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Section header with location ──
  Widget _sectionHeaderWithLocation(BuildContext context, String title, String location, ValueChanged<String> onLocationChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _showLocationPicker(context, location, onLocationChanged);
            },
            child: Row(
              children: [
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context, String currentLocation, ValueChanged<String> onLocationChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final cities = ['Lima', 'Cusco', 'Arequipa', 'Ica', 'Huaraz', 'Iquitos'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Selecciona tu ubicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              ...cities.map((c) => ListTile(
                title: Text(c, style: TextStyle(fontWeight: c == currentLocation ? FontWeight.w700 : FontWeight.w400)),
                trailing: c == currentLocation ? const Icon(Icons.check, color: AppColors.accent) : null,
                onTap: () {
                  onLocationChanged(c);
                  Navigator.pop(ctx);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ── Carousel dots ──
  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == _carouselPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── Banner CTA ──
  Widget _buildBannerCTA() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: widget.onSwitchToForYou,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primaryLight],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BUSCA TU LUGAR\nESPECIAL',
                      style: TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Recomendaciones personalizadas',
                      style: TextStyle(
                        color: AppColors.textOnDark.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  '¡Pruébalo!',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Getaway tile (Escapadas según tu tiempo) ──
  Widget _buildGetawayTile(BuildContext context, dest) {
    return GestureDetector(
      onTap: () => context.push('/destination/${dest.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: AdaptiveDestinationImage(
                  imagePath: dest.imageUrl,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dest.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dest.city}, ${dest.region}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (dest.distanceKm != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'a ${dest.distanceKm!.round()} km',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (dest.estimatedDays != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dest.estimatedDays!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
