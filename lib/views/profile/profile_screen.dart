import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/routes_controller.dart';
import '../../controllers/recommendation_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/traveler_profile_model.dart';
import '../../core/widgets/cards/stats_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().loadProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final auth = context.watch<AuthController>();
    final profileCtrl = context.watch<ProfileController>();
    final favCount = context.watch<FavoritesController>().favorites.length;
    final routeCount = context.watch<RoutesController>().routes.length;
    final recCount =
        context.watch<RecommendationController>().recommendations.length;

    final user = auth.currentUser ?? profileCtrl.user;
    final userName = user?.fullName ?? 'Viajero';
    final userEmail = user?.email ?? 'sin correo registrado';
    final profile = profileCtrl.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Header ──
            ProfileHeader(name: userName, email: userEmail),

            // ── Stats ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  StatsCard(
                    icon: Icons.favorite_rounded,
                    value: '$favCount',
                    label: 'Favoritos',
                  ),
                  const SizedBox(width: 12),
                  StatsCard(
                    icon: Icons.map_rounded,
                    value: '$routeCount',
                    label: 'Rutas',
                  ),
                  const SizedBox(width: 12),
                  StatsCard(
                    icon: Icons.auto_awesome_rounded,
                    value: '$recCount',
                    label: 'Para ti',
                  ),
                ],
              ),
            ),

            // ── Preferences summary ──
            if (profile != null) ...[
              const SizedBox(height: 24),
              _buildPreferencesSummary(profile),
            ],

            // ── Menu ──
            const SizedBox(height: 24),
            _buildMenuSection(auth),

            const SizedBox(height: 32),

            // ── App info ──
            Text(
              'PROXVEL v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSummary(TravelerProfileModel profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tus preferencias',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _prefChip('💰', profile.budget),
                _prefChip('🌤️', profile.preferredClimate),
                _prefChip('👥', 'Multitud: ${profile.crowdTolerance}'),
                ...profile.interests
                    .take(4)
                    .map<Widget>((i) => _prefChip('🏷️', i)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _prefChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(AuthController auth) {
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
              onTap: () async {
                await context.push('/profile/edit');
                // The provider will automatically update the UI since we use context.watch<AuthController>()
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
            ProfileMenuItem(
              icon: Icons.tune_rounded,
              label: 'Mis preferencias',
              onTap: () async {
                await context.push('/profile/preferences');
                if (mounted) {
                  context.read<ProfileController>().loadProfileData();
                }
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
            ProfileMenuItem(
              icon: Icons.info_outline_rounded,
              label: 'Sobre PROXVEL',
              onTap: () => _showAboutDialog(),
            ),
            const Divider(height: 1, color: AppColors.divider),
            ProfileMenuItem(
              icon: Icons.logout_rounded,
              label: 'Cerrar sesión',
              isDestructive: true,
              onTap: () => _confirmLogout(auth),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Image.asset(
              'assets/images/proxvel_logo_transparente.png',
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'PROXVEL',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aplicativo de recomendación\nturística personalizada',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Versión 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(AuthController auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Cerrar sesión?',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Podrás volver a iniciar sesión\nen cualquier momento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.border, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await auth.logout();
                      if (mounted) context.go('/welcome');
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
