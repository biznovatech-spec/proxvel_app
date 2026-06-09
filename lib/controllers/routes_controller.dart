import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../integration/services/route_service.dart';
import '../integration/local/local_storage_service.dart';

class RoutesController extends ChangeNotifier {
  final RouteService _routeService;
  final LocalStorageService _storageService;
  
  bool isLoading = false;
  List<RouteModel> routes = [];
  String? error;

  RoutesController(this._routeService, this._storageService);

  Future<void> loadRoutes() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final fetchedRoutes = await _routeService.getRoutes();
      final completedIds = _storageService.getCompletedRoutes();
      
      routes = fetchedRoutes.map((r) {
        return RouteModel(
          id: r.id,
          name: r.name,
          description: r.description,
          destinationIds: r.destinationIds,
          estimatedDurationMinutes: r.estimatedDurationMinutes,
          isCompleted: completedIds.contains(r.id),
        );
      }).toList();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleRouteCompletion(String routeId) async {
    final routeIndex = routes.indexWhere((r) => r.id == routeId);
    if (routeIndex == -1) return;

    final route = routes[routeIndex];
    final newValue = !route.isCompleted;

    if (newValue) {
      await _storageService.markRouteCompleted(routeId);
    } else {
      await _storageService.markRouteActive(routeId);
    }

    routes[routeIndex] = RouteModel(
      id: route.id,
      name: route.name,
      description: route.description,
      destinationIds: route.destinationIds,
      estimatedDurationMinutes: route.estimatedDurationMinutes,
      isCompleted: newValue,
    );
    notifyListeners();
  }
}
