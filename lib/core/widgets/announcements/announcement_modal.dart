import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/announcement_model.dart';
import '../../theme/app_colors.dart';
import '../images/adaptive_destination_image.dart';

/// Overlay del anuncio de inicio (placement 'app_start').
///
/// Se renderiza DENTRO del árbol del Home (en un Stack), no como ruta de
/// diálogo. Esto lo hace inmune a los refrescos de GoRouter durante el arranque
/// (verificación de sesión, carga de perfil), que descartaban un showDialog.
class AnnouncementModalOverlay extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onClose;

  const AnnouncementModalOverlay({
    super.key,
    required this.announcement,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final ann = announcement;
    final hasImage = (ann.backgroundImageUrl ?? '').startsWith('http');
    // Solo navegamos a rutas internas; los enlaces externos se ignoran.
    final hasInternalCta =
        (ann.ctaText ?? '').isNotEmpty && (ann.ctaUrl ?? '').startsWith('/');

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        child: GestureDetector(
          onTap: onClose, // tap fuera del card = cerrar
          child: Center(
            child: GestureDetector(
              onTap: () {}, // absorbe taps dentro del card
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Cabecera: imagen real o gradiente de marca ──
                    Stack(
                      children: [
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: hasImage
                              ? AdaptiveDestinationImage(
                                  imagePath: ann.backgroundImageUrl!,
                                )
                              : const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primaryDark,
                                        AppColors.primary,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.campaign_rounded,
                                      color: AppColors.accent,
                                      size: 44,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: onClose,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Contenido ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ann.title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ann.message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: onClose,
                                  child: Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      hasInternalCta ? 'Ahora no' : 'Entendido',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (hasInternalCta) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      onClose();
                                      context.push(ann.ctaUrl!);
                                    },
                                    child: Container(
                                      height: 48,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        ann.ctaText!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
