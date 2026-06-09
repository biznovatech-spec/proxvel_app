import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DestinationGalleryPreview extends StatelessWidget {
  final List<String> imageUrls;

  const DestinationGalleryPreview({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Galería',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to full gallery
              },
              child: const Text(
                'Ver todas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length > 3 ? 3 : imageUrls.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 100,
                  height: 120,
                  child: Image.asset(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppColors.divider),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Simple dot indicator mockup
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(true),
            const SizedBox(width: 6),
            _buildDot(false),
            const SizedBox(width: 6),
            _buildDot(false),
          ],
        ),
      ],
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.accent : AppColors.divider,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
