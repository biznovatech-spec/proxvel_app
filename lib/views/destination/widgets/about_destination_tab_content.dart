import 'package:flutter/material.dart';
import '../../../models/destination_model.dart';
import 'expandable_description_text.dart';
import 'destination_gallery_preview.dart';
import 'activities_list.dart';
import 'key_info_grid.dart';
import 'map_location_preview.dart';
import 'practical_info_card.dart';

class AboutDestinationTabContent extends StatelessWidget {
  final DestinationModel destination;

  const AboutDestinationTabContent({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Descripción
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ExpandableDescriptionText(text: destination.description),
        
        const SizedBox(height: 28),

        // 2. Galería
        if (destination.galleryImages.isNotEmpty) ...[
          DestinationGalleryPreview(imageUrls: destination.galleryImages),
          const SizedBox(height: 28),
        ],

        // 3. ¿Qué puedes hacer?
        if (destination.activities.isNotEmpty) ...[
          ActivitiesList(activities: destination.activities),
          const SizedBox(height: 28),
        ],

        // 4. Información clave
        KeyInfoGrid(destination: destination),
        
        const SizedBox(height: 28),

        // 5. Ubicación
        const MapLocationPreview(),
        
        const SizedBox(height: 28),

        // 6. Información práctica
        PracticalInfoCard(
          bestSeason: destination.bestSeason,
          estimatedDays: destination.estimatedDays,
        ),
      ],
    );
  }
}
