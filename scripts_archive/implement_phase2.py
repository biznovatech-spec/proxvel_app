import os

base_dir = r"c:\Users\danie\Documents\Proyectos\proxvell_app\lib"

files = {
    # INTEGRATION SERVICES
    "integration/api/api_client.dart": """class ApiClient {
  // Preparación futura para llamadas HTTP al backend
  // import 'package:http/http.dart' as http;
  
  Future<dynamic> get(String endpoint) async {
    throw UnimplementedError('API real no conectada aún');
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    throw UnimplementedError('API real no conectada aún');
  }
}
""",
    "integration/services/profile_service.dart": """import '../../models/user_model.dart';
import '../../models/traveler_profile_model.dart';
import '../local/local_storage_service.dart';

class ProfileService {
  final LocalStorageService _storage;
  ProfileService(this._storage);

  Future<UserModel?> getUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _storage.getUser();
  }

  Future<TravelerProfileModel?> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _storage.getProfile();
  }

  Future<void> saveProfile(TravelerProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _storage.saveProfile(profile);
  }
}
""",
    "integration/services/feedback_service.dart": """import '../../models/feedback_model.dart';
import '../local/local_storage_service.dart';

class FeedbackService {
  final LocalStorageService _storage;
  FeedbackService(this._storage);

  Future<void> submitFeedback(FeedbackModel feedback) async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _storage.saveFeedback(feedback);
  }
}
""",

    # CONTROLLERS
    "controllers/onboarding_controller.dart": """import 'package:flutter/material.dart';
import '../models/traveler_profile_model.dart';
import '../integration/services/profile_service.dart';

class OnboardingController extends ChangeNotifier {
  final ProfileService _profileService;
  bool isLoading = false;
  String? error;

  OnboardingController(this._profileService);

  Future<bool> saveProfile(TravelerProfileModel profile) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _profileService.saveProfile(profile);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
""",
    "controllers/search_controller.dart": """import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../integration/services/destination_service.dart';

class SearchController extends ChangeNotifier {
  final DestinationService _destinationService;
  bool isLoading = false;
  List<DestinationModel> results = [];
  String? error;

  SearchController(this._destinationService);

  Future<void> search(String query) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final all = await _destinationService.getDestinations();
      results = all.where((d) => d.name.toLowerCase().contains(query.toLowerCase()) || d.city.toLowerCase().contains(query.toLowerCase())).toList();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
""",
    "controllers/recommendation_controller.dart": """import 'package:flutter/material.dart';
import '../models/recommendation_result_model.dart';
import '../integration/services/recommendation_service.dart';

class RecommendationController extends ChangeNotifier {
  final RecommendationService _recommendationService;
  bool isLoading = false;
  List<RecommendationResultModel> recommendations = [];
  String? error;

  RecommendationController(this._recommendationService);

  Future<void> loadRecommendations() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      recommendations = await _recommendationService.getRecommendations();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
""",
    "controllers/destination_controller.dart": """import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../integration/services/destination_service.dart';

class DestinationController extends ChangeNotifier {
  final DestinationService _destinationService;
  bool isLoading = false;
  DestinationModel? destination;
  String? error;

  DestinationController(this._destinationService);

  Future<void> loadDestination(String id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final all = await _destinationService.getDestinations();
      destination = all.firstWhere((d) => d.id == id);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
""",
    "controllers/favorites_controller.dart": """import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../integration/services/destination_service.dart';
import '../integration/local/local_storage_service.dart';

class FavoritesController extends ChangeNotifier {
  final LocalStorageService _storage;
  final DestinationService _destinationService;
  bool isLoading = false;
  List<DestinationModel> favorites = [];
  String? error;

  FavoritesController(this._storage, this._destinationService);

  Future<void> loadFavorites() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final allIds = _storage.getFavorites();
      final allDests = await _destinationService.getDestinations();
      favorites = allDests.where((d) => allIds.contains(d.id)).toList();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final allIds = _storage.getFavorites();
    if (allIds.contains(id)) {
      await _storage.removeFavorite(id);
    } else {
      await _storage.addFavorite(id);
    }
    await loadFavorites();
  }
  
  bool isFavorite(String id) {
    return _storage.getFavorites().contains(id);
  }
}
""",
    "controllers/routes_controller.dart": """import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../integration/services/route_service.dart';

class RoutesController extends ChangeNotifier {
  final RouteService _routeService;
  bool isLoading = false;
  List<RouteModel> routes = [];
  String? error;

  RoutesController(this._routeService);

  Future<void> loadRoutes() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      routes = await _routeService.getRoutes();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
""",
    "controllers/profile_controller.dart": """import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/traveler_profile_model.dart';
import '../integration/services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService;
  bool isLoading = false;
  UserModel? user;
  TravelerProfileModel? profile;
  String? error;

  ProfileController(this._profileService);

  Future<void> loadProfileData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _profileService.getUser();
      profile = await _profileService.getProfile();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
""",
    "controllers/feedback_controller.dart": """import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../integration/services/feedback_service.dart';

class FeedbackController extends ChangeNotifier {
  final FeedbackService _feedbackService;
  bool isSubmitting = false;
  String? error;

  FeedbackController(this._feedbackService);

  Future<bool> submitFeedback(FeedbackModel feedback) async {
    isSubmitting = true;
    error = null;
    notifyListeners();
    try {
      await _feedbackService.submitFeedback(feedback);
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
""",

    # WIDGETS
    "core/widgets/buttons/proxvel_button.dart": """import 'package:flutter/material.dart';

class ProxvelButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const ProxvelButton({super.key, required this.text, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(text),
    );
  }
}
""",
    "core/widgets/cards/destination_card.dart": """import 'package:flutter/material.dart';
import '../../../models/destination_model.dart';

class DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onTap;

  const DestinationCard({super.key, required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(destination.name),
        subtitle: Text(destination.city),
        trailing: Text('\$${destination.averageCost}'),
        onTap: onTap,
      ),
    );
  }
}
""",
    "core/widgets/cards/destination_recommendation_card.dart": """import 'package:flutter/material.dart';
import '../../../models/recommendation_result_model.dart';

class DestinationRecommendationCard extends StatelessWidget {
  final RecommendationResultModel recommendation;
  final VoidCallback onTap;

  const DestinationRecommendationCard({super.key, required this.recommendation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(recommendation.destination.name),
        subtitle: Text('Compatibilidad: ${recommendation.compatibilityPercentage}%\\nEtiqueta: ${recommendation.label}'),
        onTap: onTap,
      ),
    );
  }
}
""",
    "core/widgets/chips/aspect_chip.dart": """import 'package:flutter/material.dart';

class AspectChip extends StatelessWidget {
  final String label;
  const AspectChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
""",
    "core/widgets/inputs/proxvel_text_field.dart": """import 'package:flutter/material.dart';

class ProxvelTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;

  const ProxvelTextField({super.key, required this.label, this.controller, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
""",
    "core/widgets/navigation/proxvel_bottom_navigation.dart": """import 'package:flutter/material.dart';

class ProxvelBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ProxvelBottomNavigation({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Rutas'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
""",
    "core/widgets/states/loading_view.dart": """import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
""",
    "core/widgets/states/empty_view.dart": """import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String message;
  const EmptyView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}
""",
    "core/widgets/states/error_view.dart": """import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
""",
    "core/utils/validators.dart": """class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El correo es requerido';
    if (!value.contains('@')) return 'Correo inválido';
    return null;
  }
}
""",
    # APP ROUTER
    "core/router/app_router.dart": """import 'package:go_router/go_router.dart';
import '../../views/intro/intro_screen.dart';
import '../../views/auth/welcome_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/onboarding/onboarding_profile_screen.dart';
import '../../views/main/main_layout.dart';
import '../../views/destination/destination_detail_screen.dart';
import '../../views/search/search_results_screen.dart';
import '../../views/favorites/favorites_screen.dart';
import '../../views/routes/routes_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/feedback/feedback_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/intro',
  routes: [
    GoRoute(path: '/intro', builder: (context, state) => const IntroScreen()),
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingProfileScreen()),
    GoRoute(path: '/main', builder: (context, state) => const MainLayout()),
    GoRoute(path: '/destination/:id', builder: (context, state) {
      final id = state.pathParameters['id']!;
      return DestinationDetailScreen(destinationId: id);
    }),
    GoRoute(path: '/search', builder: (context, state) => const SearchResultsScreen()),
    GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
    GoRoute(path: '/routes', builder: (context, state) => const RoutesScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/feedback/:destinationId', builder: (context, state) {
      final destId = state.pathParameters['destinationId']!;
      return FeedbackScreen(destinationId: destId);
    }),
  ],
);
""",
    # VIEWS
    "views/main/main_layout.dart": """import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../routes/routes_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/navigation/proxvel_bottom_navigation.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const RoutesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ProxvelBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
""",
    "views/home/home_screen.dart": """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/recommendation_controller.dart';
import '../../core/widgets/states/loading_view.dart';
import '../../core/widgets/cards/destination_card.dart';
import '../../core/widgets/cards/destination_recommendation_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().loadDestinations();
      context.read<RecommendationController>().loadRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeController = context.watch<HomeController>();
    final recController = context.watch<RecommendationController>();

    return Scaffold(
      appBar: AppBar(title: const Text('PROXVEL')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '¿A dónde viajas hoy?',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (val) {
                  if(val.isNotEmpty) context.push('/search?q=$val');
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Explorar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            if (homeController.isLoading)
              const LoadingView()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: homeController.destinations.length,
                itemBuilder: (context, i) {
                  final dest = homeController.destinations[i];
                  return DestinationCard(
                    destination: dest,
                    onTap: () => context.push('/destination/${dest.id}'),
                  );
                },
              ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Para Ti', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            if (recController.isLoading)
              const LoadingView()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recController.recommendations.length,
                itemBuilder: (context, i) {
                  final rec = recController.recommendations[i];
                  return DestinationRecommendationCard(
                    recommendation: rec,
                    onTap: () => context.push('/destination/${rec.destination.id}'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
""",
    "views/destination/destination_detail_screen.dart": """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/destination_controller.dart';
import '../../core/widgets/states/loading_view.dart';
import '../../core/widgets/buttons/proxvel_button.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;
  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DestinationController>().loadDestination(widget.destinationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DestinationController>();
    final dest = controller.destination;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Destino')),
      body: controller.isLoading || dest == null
          ? const LoadingView()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dest.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(dest.city, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Text(dest.description),
                  const Spacer(),
                  ProxvelButton(
                    text: 'Enviar feedback',
                    onPressed: () => context.push('/feedback/${dest.id}'),
                  ),
                ],
              ),
            ),
    );
  }
}
""",
    "views/feedback/feedback_screen.dart": """import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  final String destinationId;
  const FeedbackScreen({super.key, required this.destinationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calificar experiencia')),
      body: const Center(child: Text('Formulario de feedback simulado')),
    );
  }
}
""",
    "views/profile/profile_screen.dart": """import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Center(child: Text('Pantalla de perfil')),
    );
  }
}
""",
    "views/routes/routes_screen.dart": """import 'package:flutter/material.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rutas Turísticas')),
      body: const Center(child: Text('Lista de Rutas')),
    );
  }
}
""",
    "app.dart": """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'integration/local/local_storage_service.dart';
import 'integration/services/profile_service.dart';
import 'integration/services/destination_service.dart';
import 'integration/services/recommendation_service.dart';
import 'integration/services/route_service.dart';
import 'integration/services/feedback_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/onboarding_controller.dart';
import 'controllers/search_controller.dart';
import 'controllers/recommendation_controller.dart';
import 'controllers/destination_controller.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/routes_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/feedback_controller.dart';

class ProxvelApp extends StatelessWidget {
  const ProxvelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<LocalStorageService>(create: (_) => LocalStorageService()),
        ProxyProvider<LocalStorageService, ProfileService>(
          update: (_, storage, __) => ProfileService(storage),
        ),
        ProxyProvider<LocalStorageService, FeedbackService>(
          update: (_, storage, __) => FeedbackService(storage),
        ),
        Provider<DestinationService>(create: (_) => DestinationService()),
        Provider<RecommendationService>(create: (_) => RecommendationService()),
        Provider<RouteService>(create: (_) => RouteService()),

        // Controllers
        ChangeNotifierProxyProvider<LocalStorageService, AuthController>(
          create: (context) => AuthController(context.read<LocalStorageService>()),
          update: (context, local, auth) => auth ?? AuthController(local),
        ),
        ChangeNotifierProvider<HomeController>(create: (_) => HomeController()),
        ChangeNotifierProxyProvider<ProfileService, OnboardingController>(
          create: (context) => OnboardingController(context.read<ProfileService>()),
          update: (context, profileSvc, ctl) => ctl ?? OnboardingController(profileSvc),
        ),
        ChangeNotifierProxyProvider<DestinationService, SearchController>(
          create: (context) => SearchController(context.read<DestinationService>()),
          update: (context, destSvc, ctl) => ctl ?? SearchController(destSvc),
        ),
        ChangeNotifierProxyProvider<RecommendationService, RecommendationController>(
          create: (context) => RecommendationController(context.read<RecommendationService>()),
          update: (context, recSvc, ctl) => ctl ?? RecommendationController(recSvc),
        ),
        ChangeNotifierProxyProvider<DestinationService, DestinationController>(
          create: (context) => DestinationController(context.read<DestinationService>()),
          update: (context, destSvc, ctl) => ctl ?? DestinationController(destSvc),
        ),
        ChangeNotifierProxyProvider2<LocalStorageService, DestinationService, FavoritesController>(
          create: (context) => FavoritesController(context.read<LocalStorageService>(), context.read<DestinationService>()),
          update: (context, local, destSvc, ctl) => ctl ?? FavoritesController(local, destSvc),
        ),
        ChangeNotifierProxyProvider<RouteService, RoutesController>(
          create: (context) => RoutesController(context.read<RouteService>()),
          update: (context, routeSvc, ctl) => ctl ?? RoutesController(routeSvc),
        ),
        ChangeNotifierProxyProvider<ProfileService, ProfileController>(
          create: (context) => ProfileController(context.read<ProfileService>()),
          update: (context, profileSvc, ctl) => ctl ?? ProfileController(profileSvc),
        ),
        ChangeNotifierProxyProvider<FeedbackService, FeedbackController>(
          create: (context) => FeedbackController(context.read<FeedbackService>()),
          update: (context, feedbackSvc, ctl) => ctl ?? FeedbackController(feedbackSvc),
        ),
      ],
      child: MaterialApp.router(
        title: 'PROXVEL',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
"""
}

for rel_path, content in files.items():
    with open(os.path.join(base_dir, rel_path), "w", encoding="utf-8") as f:
        f.write(content)

print("Fase 2 implementada estructuralmente.")
