import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Premium bottom navigation with 5 tabs: Home, Mapa, Favoritos, Rutas, Perfil.
class ProxvelBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ProxvelBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.map_rounded,
                  label: 'Mapa',
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Favoritos',
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.alt_route_rounded,
                  label: 'Rutas',
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  isActive: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.navActive : AppColors.navInactive,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
