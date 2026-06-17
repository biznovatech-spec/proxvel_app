import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/announcement_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/announcements/announcement_banner.dart';
import '../../../core/widgets/cards/featured_destination_card.dart';
import '../../../core/widgets/cards/classic_destination_card.dart';
import '../../../core/widgets/cards/recent_search_chip.dart';
import '../../../core/widgets/states/loading_view.dart';

/// Contenido de la pestaña "Explorar" — catálogo abierto.
/// Solo muestra secciones que tienen datos reales. Nunca rellena la pantalla
/// con datos inventados ni con mocks.
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
  void initState() {
    super.initState();
    // Cargar anuncios internos (falla suave; no bloquea Explorar).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementController>().load(placement: 'home_top');
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _carouselCtrl.dispose();
    super.dispose();
  }

  void _startAutoScroll(int total) {
    _autoTimer?.cancel();
    if (total <= 1) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
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

    final featured = controller.featuredDestinations;
    final all = controller.allDestinations;
    final categories = controller.categories;
    final recent = controller.recentSearches;

    // Iniciar auto-scroll cuando hay destacados.
    if (featured.length > 1 && _autoTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoScroll(featured.length);
      });
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HomeController>().loadDestinations();
        if (context.mounted) {
          await context
              .read<AnnouncementController>()
              .refresh(placement: 'home_top');
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ═══ SEARCH BAR ═══
            _buildSearchBar(context),
            const SizedBox(height: 20),

            // ═══ ANUNCIO INTERNO (si hay) ═══
            const AnnouncementBanner(),

            // ═══ ERROR (si el backend falló) ═══
            if (controller.error != null && all.isEmpty) ...[
              _buildError(controller.error!),
              const SizedBox(height: 24),
            ],

            // ═══ BÚSQUEDAS RECIENTES ═══
            if (recent.isNotEmpty) ...[
              _sectionHeader('Búsquedas recientes'),
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
                    onTap: () => context.push(
                        '/search?q=${Uri.encodeComponent(recent[i].name)}'),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ═══ DESTINOS DESTACADOS ═══
            if (featured.isNotEmpty) ...[
              _sectionHeader('Destinos destacados',
                  onSeeMore: () => context.push('/search')),
              const SizedBox(height: 14),
              SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _carouselCtrl,
                  itemCount: featured.length,
                  onPageChanged: (i) => setState(() => _carouselPage = i),
                  itemBuilder: (_, i) => FeaturedDestinationCard(
                    destination: featured[i],
                    onTap: () => context.push(
                        '/destination/${featured[i].id}?source=explore'),
                  ),
                ),
              ),
              if (featured.length > 1) ...[
                const SizedBox(height: 14),
                _buildDots(featured.length),
              ],
              const SizedBox(height: 28),
            ],

            // ═══ CATEGORÍAS (reales) ═══
            if (categories.isNotEmpty) ...[
              _sectionHeader('Explora por categoría'),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _categoryChip(context, categories[i]),
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ═══ CTA A "PARA TI" (IA) ═══
            if (all.isNotEmpty) ...[
              _buildAiCta(),
              const SizedBox(height: 28),
            ],

            // ═══ TODOS LOS DESTINOS ═══
            if (all.isNotEmpty) ...[
              _sectionHeader('Todos los destinos'),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: all
                      .map((d) => ClassicDestinationCard(
                            destination: d,
                            onTap: () => context
                                .push('/destination/${d.id}?source=explore'),
                          ))
                      .toList(),
                ),
              ),
            ] else if (controller.error == null) ...[
              _buildEmpty(),
            ],

            const SizedBox(height: 32),
          ],
        ),
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

  // ── Category chip ──
  Widget _categoryChip(BuildContext context, String category) {
    return GestureDetector(
      onTap: () =>
          context.push('/search?q=${Uri.encodeComponent(category)}'),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          category,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── CTA hacia la pestaña "Para ti" (IA) ──
  Widget _buildAiCta() {
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
              colors: [AppColors.primaryDark, AppColors.primary],
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
                      'RECOMENDACIONES IA',
                      style: TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Descubre destinos según tu perfil viajero',
                      style: TextStyle(
                        color: AppColors.textOnDark.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Para ti',
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

  // ── Error state ──
  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No se pudieron cargar los destinos.\n$message',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ──
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
      child: Column(
        children: [
          Icon(Icons.travel_explore_rounded,
              size: 56, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Aún no hay destinos disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'El catálogo se mostrará aquí cuando haya destinos publicados.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
