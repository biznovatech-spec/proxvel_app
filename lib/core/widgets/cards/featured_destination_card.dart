import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/destination_model.dart';
import '../../../controllers/favorites_controller.dart';
import '../../theme/app_colors.dart';
import '../images/adaptive_destination_image.dart';

/// Card hero para el carrusel "Destinos destacados" de Explorar.
/// Honesto: solo portada real (o placeholder), nombre, ubicación, categoría y
/// favorito. Sin precio, rating, duración ni compatibilidad inventados.
class FeaturedDestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onTap;

  const FeaturedDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final location = [destination.city, destination.region]
        .where((s) => s.trim().isNotEmpty)
        .join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: AdaptiveDestinationImage(imagePath: destination.imageUrl),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.55),
                        AppColors.primary.withValues(alpha: 0.92),
                      ],
                      stops: const [0.0, 0.35, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Categoría + favorito ──
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (destination.category.trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          destination.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Consumer<FavoritesController>(
                      builder: (context, favCtrl, child) {
                        final isFav = favCtrl.isFavorite(destination.id);
                        return GestureDetector(
                          onTap: () => favCtrl.toggleFavorite(destination.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
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

              // ── Nombre + ubicación ──
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      destination.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.accent, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
