import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

/// Estado vacío honesto para cuando la IA requiere perfil viajero y el usuario
/// aún no lo ha completado. Se usa en "Para ti" y en la búsqueda con IA.
class EmptyProfileForAiState extends StatelessWidget {
  final String message;

  /// Si es true muestra un botón para ir a completar el perfil.
  final bool showAction;

  const EmptyProfileForAiState({
    super.key,
    this.message =
        'Completa tu perfil viajero para recibir recomendaciones más precisas según tus intereses, clima preferido y estilo de viaje.',
    this.showAction = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.accent,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Activa tus recomendaciones IA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (showAction) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context.push('/profile/preferences'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Completar mi perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
