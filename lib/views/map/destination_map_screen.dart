import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/maps/animated_map_marker.dart';
import '../../controllers/tourism_map_controller.dart';
import '../../models/map_marker_model.dart';

class DestinationMapScreen extends StatefulWidget {
  final String destinationId;
  const DestinationMapScreen({super.key, required this.destinationId});

  @override
  State<DestinationMapScreen> createState() => _DestinationMapScreenState();
}

class _DestinationMapScreenState extends State<DestinationMapScreen> {
  final MapController _mapController = MapController();

  final LatLng _initialCenter = const LatLng(-9.1900, -75.0152);
  final double _initialZoom = 5.0;
  
  MapMarkerModel? _lastSelectedMarker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<TourismMapController>();
      await controller.loadMarkers();
      
      try {
        final marker = controller.markers.firstWhere((m) => m.destinationId == widget.destinationId);
        controller.selectDestination(marker);
      } catch (e) {
        // Destination not found
      }
    });
  }

  void _handleStateChanges(TourismMapController controller) {
    if (controller.selectedMarker != null && controller.selectedMarker != _lastSelectedMarker && controller.userLocation != null) {
      _lastSelectedMarker = controller.selectedMarker;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints([
              controller.userLocation!,
              LatLng(controller.selectedMarker!.latitude, controller.selectedMarker!.longitude),
            ]),
            padding: const EdgeInsets.all(50.0),
          ),
        );
      });
    } else if (controller.selectedMarker == null && _lastSelectedMarker != null) {
      _lastSelectedMarker = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_initialCenter, _initialZoom);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubicación del Destino',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<TourismMapController>().clearSelection();
            context.pop();
          },
        ),
      ),
      body: Consumer<TourismMapController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.selectedMarker == null) {
            return Center(
              child: Text('Error al cargar mapa: ${controller.errorMessage}'),
            );
          }
          
          _handleStateChanges(controller);

          // Determinar marcadores a mostrar
          List<Marker> markers = [];
          List<Polyline> polylines = [];

          if (controller.selectedMarker != null) {
            // Mostrar solo el destino seleccionado y el usuario
            final m = controller.selectedMarker!;
            markers.add(
              Marker(
                point: LatLng(m.latitude, m.longitude),
                width: 50,
                height: 50,
                child: const AnimatedMapMarker(color: AppColors.primary),
              ),
            );

            if (controller.userLocation != null) {
              markers.add(
                Marker(
                  point: controller.userLocation!,
                  width: 50,
                  height: 50,
                  child: const AnimatedMapMarker(color: Colors.blue, icon: Icons.person_pin_circle),
                ),
              );

              polylines.add(
                Polyline(
                  points: [controller.userLocation!, LatLng(m.latitude, m.longitude)],
                  strokeWidth: 4.0,
                  color: Colors.blueAccent.withValues(alpha: 0.7),
                ),
              );
            }
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(-9.1900, -75.0152),
                  initialZoom: 5.0,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.proxvel_app',
                  ),
                  if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                  MarkerLayer(markers: markers),
                ],
              ),
              if (controller.selectedMarker != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildDistanceOverlay(context, controller),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDistanceOverlay(BuildContext context, TourismMapController controller) {
    final m = controller.selectedMarker!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.red.shade50,
                child: Text(
                  controller.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            Text(
              m.destination,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              m.city != null ? '${m.city}, ${m.region}' : m.region ?? '',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (controller.distanceKm != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_car, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Distancia estimada: ${controller.distanceKm!.toStringAsFixed(1)} km',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else if (controller.errorMessage == null)
              const Center(child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(),
              )),
          ],
        ),
      ),
    );
  }
}
