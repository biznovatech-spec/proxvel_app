import os

base_dir = r"c:\Users\danie\Documents\Proyectos\proxvell_app\lib"

files = {
    "core/theme/app_colors.dart": """import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF26A69A);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFB300);
}
""",
    "core/theme/app_text_styles.dart": """import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
""",
    "core/theme/app_theme.dart": """import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
""",
    "core/router/app_router.dart": """import 'package:go_router/go_router.dart';
import '../../views/intro/intro_screen.dart';
import '../../views/auth/welcome_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/onboarding/onboarding_profile_screen.dart';
import '../../views/main/main_layout.dart';
import '../../views/destination/destination_detail_screen.dart';
import '../../views/search/search_results_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/intro',
  routes: [
    GoRoute(
      path: '/intro',
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingProfileScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainLayout(),
    ),
    GoRoute(
      path: '/destination/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DestinationDetailScreen(destinationId: id);
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchResultsScreen(),
    ),
  ],
);
""",
    "integration/local/local_storage_service.dart": """import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../models/traveler_profile_model.dart';
import '../../models/feedback_model.dart';

class LocalStorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Session
  Future<void> setSessionActive(bool isActive) async {
    await _prefs?.setBool('is_session_active', isActive);
  }

  bool get isSessionActive => _prefs?.getBool('is_session_active') ?? false;

  // Intro Seen
  Future<void> setIntroSeen(bool seen) async {
    await _prefs?.setBool('intro_seen', seen);
  }

  bool get introSeen => _prefs?.getBool('intro_seen') ?? false;

  // User
  Future<void> saveUser(UserModel user) async {
    await _prefs?.setString('user', jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final str = _prefs?.getString('user');
    if (str != null) return UserModel.fromJson(jsonDecode(str));
    return null;
  }

  // Profile
  Future<void> saveProfile(TravelerProfileModel profile) async {
    await _prefs?.setString('profile', jsonEncode(profile.toJson()));
  }

  TravelerProfileModel? getProfile() {
    final str = _prefs?.getString('profile');
    if (str != null) return TravelerProfileModel.fromJson(jsonDecode(str));
    return null;
  }

  // Favorites
  Future<void> addFavorite(String destinationId) async {
    final list = getFavorites();
    if (!list.contains(destinationId)) {
      list.add(destinationId);
      await _prefs?.setStringList('favorites', list);
    }
  }
  
  Future<void> removeFavorite(String destinationId) async {
    final list = getFavorites();
    if (list.contains(destinationId)) {
      list.remove(destinationId);
      await _prefs?.setStringList('favorites', list);
    }
  }

  List<String> getFavorites() {
    return _prefs?.getStringList('favorites') ?? [];
  }

  // Feedback
  Future<void> saveFeedback(FeedbackModel feedback) async {
    final list = getFeedbackList();
    list.add(feedback);
    final strList = list.map((f) => jsonEncode(f.toJson())).toList();
    await _prefs?.setStringList('feedback', strList);
  }

  List<FeedbackModel> getFeedbackList() {
    final strList = _prefs?.getStringList('feedback') ?? [];
    return strList.map((str) => FeedbackModel.fromJson(jsonDecode(str))).toList();
  }
}
"""
}

for rel_path, content in files.items():
    with open(os.path.join(base_dir, rel_path), "w", encoding="utf-8") as f:
        f.write(content)

print("Archivos core/router/theme y local_storage_service implementados.")
