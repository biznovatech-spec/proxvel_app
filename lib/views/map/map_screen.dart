import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/tourism_map_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  
  // Coordenadas centrales por defecto (ej. Centro aproximado de Perú)
  final LatLng _initialCenter = const LatLng(-9.1900, -75.0152);
  final double _initialZoom = 5.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TourismMapController>().loadMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Turístico', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TourismMapController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text('Error al cargar mapa: ${controller.errorMessage}'));
          }

          final markers = controller.filteredMarkers.map((m) {
            return Marker(
              point: LatLng(m.latitude, m.longitude),
              width: 50,
              height: 50,
              child: _AnimatedMapMarker(
                onTap: () => context.push('/destination/${m.destinationId}'),
              ),
            );
          }).toList();

          return Column(
            children: [
              _buildCategoryFilters(context, controller),
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: _initialZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.proxvel_app',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context, TourismMapController controller) {
    final categories = controller.availableCategories;
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = controller.selectedCategory == null;
            return FilterChip(
              label: const Text('Todos'),
              selected: isSelected,
              onSelected: (_) => controller.setCategory(null),
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }
          final category = categories[index - 1];
          final isSelected = controller.selectedCategory == category;
          return FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => controller.setCategory(category),
            selectedColor: AppColors.primary.withOpacity(0.2),
            checkmarkColor: AppColors.primary,
          );
        },
      ),
    );
  }
}

class _AnimatedMapMarker extends StatelessWidget {
  final VoidCallback onTap;

  const _AnimatedMapMarker({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
