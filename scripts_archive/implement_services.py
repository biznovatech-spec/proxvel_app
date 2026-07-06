import os

base_dir = r"c:\Users\danie\Documents\Proyectos\proxvell_app\lib"

files = {
    "integration/mock/mock_destination_data_source.dart": """import '../../models/destination_model.dart';

class MockDestinationDataSource {
  static final List<DestinationModel> destinations = [
    DestinationModel(
      id: '1',
      name: 'Machu Picchu',
      city: 'Cusco',
      region: 'Cusco',
      category: 'Arqueológico',
      description: 'Ciudadela inca en lo alto de los Andes.',
      imageUrl: 'https://via.placeholder.com/300',
      averageCost: 500.0,
      climate: 'Templado',
      crowdLevel: 'Alto',
      rating: 4.9,
      aspects: ['atractivos turísticos', 'clima', 'seguridad'],
    ),
    DestinationModel(
      id: '2',
      name: 'Circuito Mágico del Agua',
      city: 'Lima',
      region: 'Lima',
      category: 'Entretenimiento',
      description: 'Parque con fuentes de agua interactivas.',
      imageUrl: 'https://via.placeholder.com/300',
      averageCost: 20.0,
      climate: 'Húmedo',
      crowdLevel: 'Medio',
      rating: 4.5,
      aspects: ['entretenimiento', 'seguridad', 'accesibilidad'],
    ),
    // Add more mocks as needed...
  ];
}
""",
    "integration/mock/mock_route_data_source.dart": """import '../../models/route_model.dart';

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
""",
    "integration/mock/mock_recommendation_data_source.dart": """import '../../models/recommendation_result_model.dart';
import 'mock_destination_data_source.dart';

class MockRecommendationDataSource {
  static List<RecommendationResultModel> getRecommendations() {
    final dest = MockDestinationDataSource.destinations.first;
    return [
      RecommendationResultModel(
        id: 'rec1',
        destination: dest,
        compatibilityPercentage: 95.0,
        finalScore: 4.8,
        label: 'Recomendado',
        reasons: ['Ideal para tu presupuesto', 'Clima perfecto para ti'],
        aspectScores: [],
        contextSignals: [],
      )
    ];
  }
}
""",
    "integration/services/destination_service.dart": """import '../../models/destination_model.dart';
import '../mock/mock_destination_data_source.dart';

class DestinationService {
  Future<List<DestinationModel>> getDestinations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDestinationDataSource.destinations;
  }
}
""",
    "integration/services/route_service.dart": """import '../../models/route_model.dart';
import '../mock/mock_route_data_source.dart';

class RouteService {
  Future<List<RouteModel>> getRoutes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockRouteDataSource.routes;
  }
}
""",
    "integration/services/recommendation_service.dart": """import '../../models/recommendation_result_model.dart';
import '../mock/mock_recommendation_data_source.dart';

class RecommendationService {
  Future<List<RecommendationResultModel>> getRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockRecommendationDataSource.getRecommendations();
  }
}
""",
    "controllers/auth_controller.dart": """import 'package:flutter/material.dart';
import '../integration/local/local_storage_service.dart';

class AuthController extends ChangeNotifier {
  final LocalStorageService _storage;

  AuthController(this._storage);

  bool get isAuthenticated => _storage.isSessionActive;

  Future<void> login(String email, String password) async {
    // Mock login logic
    await Future.delayed(const Duration(seconds: 1));
    await _storage.setSessionActive(true);
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.setSessionActive(false);
    notifyListeners();
  }
}
""",
    "controllers/home_controller.dart": """import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../integration/services/destination_service.dart';

class HomeController extends ChangeNotifier {
  final DestinationService _service = DestinationService();
  bool isLoading = false;
  List<DestinationModel> destinations = [];

  Future<void> loadDestinations() async {
    isLoading = true;
    notifyListeners();
    destinations = await _service.getDestinations();
    isLoading = false;
    notifyListeners();
  }
}
"""
}

for rel_path, content in files.items():
    with open(os.path.join(base_dir, rel_path), "w", encoding="utf-8") as f:
        f.write(content)

print("Servicios y Controladores base implementados.")
