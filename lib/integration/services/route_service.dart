import '../../models/route_model.dart';
import '../mock/mock_route_data_source.dart';

class RouteService {
  Future<List<RouteModel>> getRoutes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockRouteDataSource.routes;
  }
}
