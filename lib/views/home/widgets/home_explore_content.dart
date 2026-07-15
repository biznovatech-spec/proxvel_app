import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/announcement_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/announcements/announcement_banner.dart';
import '../../../core/widgets/cards/classic_destination_card.dart';
import '../../../core/widgets/cards/recent_search_chip.dart';
import '../../../models/destination_model.dart';
import '../../../core/widgets/images/adaptive_destination_image.dart';
import '../../../core/widgets/carousels/coverflow_carousel.dart';
import '../../../controllers/archive_controller.dart' as import_archive_controller;

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
  final int _carouselPage = 0;
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
    final archiveCtrl = context.watch<import_archive_controller.ArchiveController>();

    final featured = controller.featuredDestinations.where((d) => !archiveCtrl.isArchived(d.id)).toList();
    final all = controller.allDestinations.where((d) => !archiveCtrl.isArchived(d.id)).toList();
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

            // ═══ CATEGORÍAS (reales) movidas arriba ═══
            if (categories.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Explora nuevos horizontes',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _categoryChip(context, categories[i], i == 0),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // ═══ DESTINOS DESTACADOS (Coverflow Carousel) ═══
            if (featured.isNotEmpty) ...[
              CoverflowCarousel(
                destinations: featured,
                onDestinationTap: (dest) => context.push('/destination/${dest.id}?source=explore'),
              ),
              const SizedBox(height: 32),
            ],


            // ═══ CTA A "PARA TI" (IA) ═══
            if (all.isNotEmpty) ...[
              _buildAiCta(),
              const SizedBox(height: 32),
            ],

            // ═══ TOP TENDENCIAS ═══
            if (all.isNotEmpty) ...[
              _buildTrendingList(context, all),
              const SizedBox(height: 24),
            ],

            // ═══ ESPECIAL DE TEMPORADA ═══
            if (all.length > 1) ...[
              _buildSeasonalSpotlight(context, all[all.length ~/ 2]),
              const SizedBox(height: 32),
            ],

            // ═══ DESTINOS CATEGORIZADOS (Diseño Netflix) ═══
            if (all.isNotEmpty) ...[
              _buildCategorizedSections(context, all),
            ] else if (controller.error == null) ...[
              _buildEmpty(),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          height: 60,
          padding: const EdgeInsets.only(left: 24, right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: AppColors.textMuted, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '¿A dónde viajas hoy?',
                  style: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.tune_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
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
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (onSeeMore != null)
            GestureDetector(
              onTap: onSeeMore,
              child: Text(
                'Ver más',
                style: GoogleFonts.poppins(
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

  Widget _categoryChip(BuildContext context, String category, bool isFirst) {
    return GestureDetector(
      onTap: () =>
          context.push('/search?q=${Uri.encodeComponent(category)}'),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isFirst ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isFirst ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          category,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isFirst ? FontWeight.w600 : FontWeight.w500,
            color: isFirst ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildAiCta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: widget.onSwitchToForYou,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.25),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI RECOMMENDATIONS',
                      style: GoogleFonts.poppins(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Destinos según\ntu perfil',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
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


  // ── Top Tendencias ──
  Widget _buildTrendingList(BuildContext context, List<DestinationModel> all) {
    if (all.isEmpty) return const SizedBox.shrink();
    final trending = all.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Top Tendencias'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(trending.length, (i) {
              final dest = trending[i];
              return GestureDetector(
                onTap: () => context.push('/destination/${dest.id}?source=explore'),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Text(
                        '0${i + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: AppColors.border,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dest.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              dest.city,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Especial de Temporada ──
  Widget _buildSeasonalSpotlight(BuildContext context, DestinationModel? spot) {
    if (spot == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => context.push('/destination/${spot.id}?source=explore'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: 380,
        color: AppColors.primaryDark,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.7,
                child: AdaptiveDestinationImage(imagePath: spot.imageUrl),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESPECIAL DE TEMPORADA',
                    style: GoogleFonts.poppins(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    spot.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Descubrir',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
    );
  }

  // ── Secciones Categorizadas (Diseño Netflix) ──
  Widget _buildCategorizedSections(BuildContext context, List<DestinationModel> all) {
    // 1. Agrupar por categoría
    final Map<String, List<DestinationModel>> grouped = {};
    for (var dest in all) {
      if (dest.category.trim().isEmpty) continue;
      if (!grouped.containsKey(dest.category)) {
        grouped[dest.category] = [];
      }
      grouped[dest.category]!.add(dest);
    }

    // 2. Construir los carruseles
    final List<Widget> sections = [];
    for (var entry in grouped.entries) {
      final category = entry.key;
      final dests = entry.value;
      if (dests.isEmpty) continue;

      sections.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(category, onSeeMore: () {
              context.push('/search?q=${Uri.encodeComponent(category)}');
            }),
            const SizedBox(height: 14),
            SizedBox(
              height: 155, // Espacio suficiente para la tarjeta y su sombra
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: dests.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (_, i) {
                  return SizedBox(
                    width: 320, // Ancho fijo para que no reviente el scroll
                    child: ClassicDestinationCard(
                      destination: dests[i],
                      onTap: () => context.push('/destination/${dests[i].id}?source=explore'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        )
      );
    }

    return Column(children: sections);
  }
}
