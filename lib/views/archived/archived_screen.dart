import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../controllers/archive_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cards/classic_destination_card.dart';
import '../../../models/destination_model.dart';

class ArchivedScreen extends StatefulWidget {
  const ArchivedScreen({super.key});

  @override
  State<ArchivedScreen> createState() => _ArchivedScreenState();
}

class _ArchivedScreenState extends State<ArchivedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArchiveController>().loadArchives();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Archivados',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ArchiveController>(
        builder: (context, arcCtrl, _) {
          if (arcCtrl.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (arcCtrl.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudieron cargar los archivados',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      arcCtrl.error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: arcCtrl.loadArchives,
                      child: const Text('Reintentar'),
                    )
                  ],
                ),
              ),
            );
          }

          if (arcCtrl.archives.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.archive_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sin archivos',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aquí aparecerán los destinos que hayas decidido ocultar.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: arcCtrl.loadArchives,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: arcCtrl.archives.length,
              itemBuilder: (context, index) {
                final arc = arcCtrl.archives[index];
                // Creamos un DestinationModel mockeado a partir del ArchiveModel 
                // para reutilizar la ClassicDestinationCard
                final dest = DestinationModel(
                  id: arc.destinationId,
                  name: arc.name,
                  city: arc.city ?? '',
                  region: arc.region ?? '',
                  category: arc.category ?? '',
                  description: '',
                  imageUrl: arc.coverImageUrl ?? '',
                  averageCost: 0,
                  climate: '',
                  crowdLevel: '',
                  rating: 0,
                  aspects: const [],
                );

                return ClassicDestinationCard(
                  destination: dest,
                  onTap: () {
                    context.push('/destination/${dest.id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
