import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'integration/api/api_client.dart';
import 'integration/local/local_storage_service.dart';
import 'integration/services/profile_service.dart';
import 'integration/services/destination_service.dart';
import 'integration/services/recommendation_service.dart';
import 'integration/services/route_service.dart';
import 'integration/services/feedback_service.dart';
import 'integration/services/tourism_service.dart';
import 'integration/services/review_service.dart';
import 'integration/services/user_service.dart';
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
import 'controllers/my_reviews_controller.dart';

class ProxvelApp extends StatelessWidget {
  final LocalStorageService storageService;

  const ProxvelApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<LocalStorageService>.value(value: storageService),
        Provider<ApiClient>(create: (_) => ApiClient()),
        ProxyProvider2<LocalStorageService, ApiClient, ProfileService>(
          update: (_, storage, api, previous) =>
              ProfileService(storage, apiClient: api),
        ),
        ProxyProvider2<LocalStorageService, ApiClient, FeedbackService>(
          update: (_, storage, api, previous) => FeedbackService(storage, apiClient: api),
        ),
        ProxyProvider<ApiClient, DestinationService>(
          update: (_, api, previous) => DestinationService(apiClient: api),
        ),
        ProxyProvider<ApiClient, TourismService>(
          update: (_, api, previous) => TourismService(apiClient: api),
        ),
        ProxyProvider<ApiClient, ReviewService>(
          update: (_, api, previous) => ReviewService(apiClient: api),
        ),
        ProxyProvider<ApiClient, RecommendationService>(
          update: (_, api, previous) => RecommendationService(apiClient: api),
        ),
        ProxyProvider<ApiClient, UserService>(
          update: (_, api, previous) => UserService(apiClient: api),
        ),
        Provider<RouteService>(create: (_) => RouteService()),

        // Controllers
        ChangeNotifierProxyProvider2<LocalStorageService, UserService, AuthController>(
          create: (context) => AuthController(context.read<LocalStorageService>(), context.read<UserService>()),
          update: (context, local, userSvc, auth) => auth ?? AuthController(local, userSvc),
        ),
        ChangeNotifierProvider<HomeController>(create: (_) => HomeController()),
        ChangeNotifierProxyProvider<ProfileService, OnboardingController>(
          create: (context) => OnboardingController(context.read<ProfileService>()),
          update: (context, profileSvc, ctl) => ctl ?? OnboardingController(profileSvc),
        ),
        ChangeNotifierProxyProvider2<DestinationService, LocalStorageService, SearchController>(
          create: (context) => SearchController(
            context.read<DestinationService>(),
            context.read<LocalStorageService>(),
          ),
          update: (context, destSvc, localSvc, ctl) => ctl ?? SearchController(destSvc, localSvc),
        ),
        ChangeNotifierProxyProvider<RecommendationService, RecommendationController>(
          create: (context) => RecommendationController(context.read<RecommendationService>()),
          update: (context, recSvc, ctl) => ctl ?? RecommendationController(recSvc),
        ),
        ChangeNotifierProxyProvider3<DestinationService, TourismService, ReviewService, DestinationController>(
          create: (context) => DestinationController(
            context.read<DestinationService>(),
            context.read<TourismService>(),
            context.read<ReviewService>(),
          ),
          update: (context, destSvc, tourismSvc, reviewSvc, ctl) => 
            ctl ?? DestinationController(destSvc, tourismSvc, reviewSvc),
        ),
        ChangeNotifierProxyProvider2<LocalStorageService, DestinationService, FavoritesController>(
          create: (context) => FavoritesController(context.read<LocalStorageService>(), context.read<DestinationService>()),
          update: (context, local, destSvc, ctl) => ctl ?? FavoritesController(local, destSvc),
        ),
        ChangeNotifierProxyProvider2<RouteService, LocalStorageService, RoutesController>(
          create: (context) => RoutesController(
            context.read<RouteService>(),
            context.read<LocalStorageService>(),
          ),
          update: (context, routeSvc, localSvc, ctl) => ctl ?? RoutesController(routeSvc, localSvc),
        ),
        ChangeNotifierProxyProvider3<ProfileService, LocalStorageService, UserService, ProfileController>(
          create: (context) => ProfileController(
            context.read<ProfileService>(),
            context.read<LocalStorageService>(),
            userService: context.read<UserService>(),
          ),
          update: (context, profileSvc, localSvc, userSvc, ctl) => 
            ctl ?? ProfileController(profileSvc, localSvc, userService: userSvc),
        ),
        ChangeNotifierProxyProvider<FeedbackService, FeedbackController>(
          create: (context) => FeedbackController(context.read<FeedbackService>()),
          update: (context, feedbackSvc, ctl) => ctl ?? FeedbackController(feedbackSvc),
        ),
        ChangeNotifierProxyProvider<ReviewService, MyReviewsController>(
          create: (context) => MyReviewsController(context.read<ReviewService>()),
          update: (context, reviewSvc, ctl) => ctl ?? MyReviewsController(reviewSvc),
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
