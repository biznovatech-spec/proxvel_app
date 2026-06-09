import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/destination_model.dart';

class KeyInfoGrid extends StatelessWidget {
  final DestinationModel destination;

  const KeyInfoGrid({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información clave',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _KeyInfoItem(
                    icon: Icons.category_outlined,
                    label: 'Categoría',
                    value: destination.category,
                  ),
                  const SizedBox(height: 16),
                  _KeyInfoItem(
                    icon: Icons.landscape_outlined,
                    label: 'Altitud',
                    value: destination.altitudeM != null
                        ? '${destination.altitudeM!.toStringAsFixed(0)} m\ns. n. m.'
                        : 'N/A',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _KeyInfoItem(
                    icon: Icons.account_balance_outlined,
                    label: 'Tipo',
                    value: destination.type ?? 'N/A',
                  ),
                  const SizedBox(height: 16),
                  _KeyInfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'Región',
                    value: destination.region,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _KeyInfoItem(
                    icon: Icons.star_border_rounded,
                    label: 'Jerarquía',
                    value: destination.hierarchy ?? 'N/A',
                  ),
                  const SizedBox(height: 16),
                  _KeyInfoItem(
                    icon: Icons.map_outlined,
                    label: 'Ciudad / Zona',
                    value: destination.city,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _KeyInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
