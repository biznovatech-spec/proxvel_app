import 'package:flutter/material.dart';
import '../../../models/destination_model.dart';
import '../../../models/tourism_catalog_model.dart';
import '../../../core/theme/app_colors.dart';
import 'expandable_description_text.dart';
import 'destination_gallery_preview.dart';
import 'activities_list.dart';
import 'key_info_grid.dart';
import 'map_location_preview.dart';
import 'practical_info_card.dart';

class AboutDestinationTabContent extends StatelessWidget {
  final DestinationModel destination;
  final TourismCatalogModel? tourismInfo;

  const AboutDestinationTabContent({
    super.key,
    required this.destination,
    this.tourismInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0. Información Oficial MINCETUR
        if (tourismInfo != null) ...[
          _buildOfficialInfo(tourismInfo!),
          const SizedBox(height: 28),
        ],

        // 1. Descripción
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ExpandableDescriptionText(text: tourismInfo?.description ?? destination.description),
        
        const SizedBox(height: 28),

        // 2. Galería
        if (destination.galleryImages.isNotEmpty) ...[
          DestinationGalleryPreview(imageUrls: destination.galleryImages),
          const SizedBox(height: 28),
        ],

        // 3. ¿Qué puedes hacer?
        if (destination.activities.isNotEmpty || (tourismInfo?.activitiesSummary != null)) ...[
          if (tourismInfo?.activitiesSummary != null) ...[
            const Text(
              'Actividades',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              tourismInfo!.activitiesSummary!,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ] else ...[
            ActivitiesList(activities: destination.activities),
          ],
          const SizedBox(height: 28),
        ],

        // 4. Información clave (jerarquía, altitud, accesibilidad)
        if (tourismInfo?.accessibilitySummary != null) ...[
          const Text(
            'Accesibilidad',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            tourismInfo!.accessibilitySummary!,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 28),
        ],

        KeyInfoGrid(
          destination: destination,
          tourismInfo: tourismInfo,
        ),
        
        const SizedBox(height: 28),

        // 5. Ubicación
        MapLocationPreview(
          latitude: tourismInfo?.latitude,
          longitude: tourismInfo?.longitude,
        ),
        
        const SizedBox(height: 28),

        // 6. Información práctica
        PracticalInfoCard(
          bestSeason: destination.bestSeason,
          estimatedDays: destination.estimatedDays,
        ),
      ],
    );
  }

  Widget _buildOfficialInfo(TourismCatalogModel info) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Información Oficial (MINCETUR)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (info.officialName != null) _infoRow('Nombre oficial:', info.officialName!),
          _infoRow('Fuente:', 'Inventario de Recursos Turísticos del Perú - MINCETUR'),
          if (info.officialSourceCode != null) _infoRow('Código de fuente:', info.officialSourceCode!),
          if (info.officialSourceUrl != null) _infoRow('Link oficial:', info.officialSourceUrl!),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(),
          ),
          if (info.department != null && info.province != null) 
            _infoRow('Ubicación:', '${info.district != null ? '${info.district}, ' : ''}${info.province}, ${info.department}'),
          if (info.type != null) _infoRow('Tipo:', info.type!),
          if (info.subtype != null) _infoRow('Subtipo:', info.subtype!),
          if (info.hierarchy != null && info.hierarchy != 'null') _infoRow('Jerarquía:', info.hierarchy!),
          if (info.experienceType != null) _infoRow('Experiencia:', info.experienceType!),
          if (info.altitudeM != null) _infoRow('Altitud:', '${info.altitudeM} m.s.n.m.'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
