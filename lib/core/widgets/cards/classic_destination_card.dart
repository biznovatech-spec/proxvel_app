import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/destination_model.dart';
import '../../../controllers/favorites_controller.dart';
import '../../theme/app_colors.dart';
import '../images/adaptive_destination_image.dart';
import 'ai_compatibility_badge.dart';

/// Card de catálogo abierto (pestaña Explorar).
/// Muestra solo datos reales: portada (o placeholder honesto), nombre,
/// ubicación, categoría y favorito. NO muestra precio, rating, distancia
/// ni duración inventados.
///
/// [compatibility] es opcional y solo se pinta cuando el backend entregó un
/// porcentaje real y la preferencia de IA aplica (dato secundario y discreto).
class ClassicDestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onTap;
  final int? compatibility;

  const ClassicDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.compatibility,
  });

  @override
  Widget build(BuildContext context) {
    final location = [
      destination.city,
      destination.region,
    ].where((s) => s.trim().isNotEmpty).join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        // IntrinsicHeight acota la altura del Row (anclada por la imagen de
        // 118px) para que CrossAxisAlignment.stretch funcione dentro de un
        // scroll vertical. Sin esto, el Row recibe altura infinita y revienta
        // el layout de toda la pantalla.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Imagen ──
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: SizedBox(
                  width: 118,
                  height: 118,
                  child: AdaptiveDestinationImage(
                    imagePath: destination.imageUrl,
                  ),
                ),
              ),

              // ── Info ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        destination.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (destination.category.trim().isNotEmpty)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  destination.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          if (compatibility != null) ...[
                            const SizedBox(width: 8),
                            AiCompatibilityBadge(
                              compatibility: compatibility!,
                              compact: true,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Favorito ──
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: Consumer<FavoritesController>(
                  builder: (context, favCtrl, _) {
                    final isFav = favCtrl.isFavorite(destination.id);
                    return GestureDetector(
                      onTap: () => favCtrl.toggleFavorite(destination.id),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.error : AppColors.textMuted,
                        size: 22,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
