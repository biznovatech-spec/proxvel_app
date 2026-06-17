import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'profile_menu_item.dart';

/// Sección de menú del perfil (editar, preferencias, reseñas, sobre, logout).
/// Recibe los callbacks desde la pantalla para mantener la navegación y los
/// diálogos en un único lugar.
class ProfileMenuSection extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onPreferences;
  final VoidCallback onMyReviews;
  final VoidCallback onAbout;
  final VoidCallback onLogout;

  const ProfileMenuSection({
    super.key,
    required this.onEditProfile,
    required this.onPreferences,
    required this.onMyReviews,
    required this.onAbout,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            ProfileMenuItem(
              icon: Icons.edit_rounded,
              label: 'Editar perfil',
              onTap: onEditProfile,
            ),
            const Divider(height: 1, color: AppColors.divider),
            ProfileMenuItem(
              icon: Icons.tune_rounded,
              label: 'Mis preferencias',
              onTap: onPreferences,
            ),
            const Divider(height: 1, color: AppColors.divider),
            ProfileMenuItem(
              icon: Icons.rate_review_rounded,
              label: 'Mis reseñas',
              onTap: onMyReviews,
            ),
            const Divider(height: 1, color: AppColors.divider),
            ProfileMenuItem(
              icon: Icons.info_outline_rounded,
              label: 'Sobre PROXVEL',
              onTap: onAbout,
            ),
            const Divider(height: 1, color: AppColors.divider),
            ProfileMenuItem(
              icon: Icons.logout_rounded,
              label: 'Cerrar sesión',
              isDestructive: true,
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
