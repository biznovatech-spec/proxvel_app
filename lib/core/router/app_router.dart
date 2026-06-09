import 'package:go_router/go_router.dart';
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
import '../../views/profile/edit_profile_screen.dart';
import '../../views/profile/preferences_screen.dart';
import '../../views/feedback/feedback_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(path: '/intro', builder: (context, state) => const IntroScreen()),
    GoRoute(path: '/welcome', pageBuilder: (context, state) => const NoTransitionPage(child: WelcomeScreen())),
    GoRoute(path: '/login', pageBuilder: (context, state) => const NoTransitionPage(child: LoginScreen())),
    GoRoute(path: '/register', pageBuilder: (context, state) => const NoTransitionPage(child: RegisterScreen())),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingProfileScreen()),
    GoRoute(path: '/main', builder: (context, state) => const MainLayout()),
    GoRoute(path: '/destination/:id', builder: (context, state) {
      final id = state.pathParameters['id']!;
      return DestinationDetailScreen(destinationId: id);
    }),
    GoRoute(path: '/search', builder: (context, state) {
      final query = state.uri.queryParameters['q'] ?? '';
      return SearchResultsScreen(initialQuery: query);
    }),
    GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
    GoRoute(path: '/routes', builder: (context, state) => const RoutesScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
    GoRoute(path: '/profile/preferences', builder: (context, state) => const PreferencesScreen()),
    GoRoute(path: '/feedback/:destinationId', builder: (context, state) {
      final destId = state.pathParameters['destinationId']!;
      return FeedbackScreen(destinationId: destId);
    }),
  ],
);
