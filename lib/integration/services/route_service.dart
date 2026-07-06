/// STANDBY — Rutas en standby por decisión de producto (Fase 0.1).
///
/// Este servicio usa mock incondicional (sin backend real).
/// No se usa en ningún flujo visible de la app.
/// Preservado para una futura fase donde se reactive la funcionalidad de Rutas.
///
/// NO USAR hasta que se implemente el backend de rutas y se reactive
/// la pantalla en el bottom navigation.
import '../../models/route_model.dart';
import '../mock/mock_route_data_source.dart';

@Deprecated('Rutas en standby — Fase 0.1. No usar hasta reactivación.')
class RouteService {
  Future<List<RouteModel>> getRoutes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockRouteDataSource.routes;
  }
}
