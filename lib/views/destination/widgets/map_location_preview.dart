import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MapLocationPreview extends StatelessWidget {
  const MapLocationPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8), // Light map background color
            borderRadius: BorderRadius.circular(16),
            // We would normally use a map plugin here or a static map image.
            // Using a simple pattern to simulate a map background.
            image: const DecorationImage(
              image: AssetImage('assets/images/rio-amazonas.png'), // Placeholder
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white70,
                BlendMode.lighten,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Map Pin
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.accent,
                    size: 40,
                  ),
                  Container(
                    width: 12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ],
              ),
              // "Ver en mapa" button
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ver en mapa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
