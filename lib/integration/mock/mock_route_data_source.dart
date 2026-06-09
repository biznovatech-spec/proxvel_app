import '../../models/route_model.dart';

class MockRouteDataSource {
  static final List<RouteModel> routes = [
    RouteModel(
      id: 'r1',
      name: 'Ruta Inca Mágica',
      description: 'Recorre el valle sagrado y Machu Picchu.',
      destinationIds: ['1'],
      estimatedDurationMinutes: 1440,
    )
  ];
}
