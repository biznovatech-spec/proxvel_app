import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../models/traveler_profile_model.dart';

class LocalStorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Inject default user for easy testing
    if (getAllRegisteredUsers().isEmpty) {
      final defaultUser = UserModel(
        id: 'default_1',
        name: 'Viajero',
        lastName: 'Frecuente',
        email: 'test@proxvel.com',
        password: 'password123',
      );
      await registerUser(defaultUser);
    }
  }

  // ── Session ──
  Future<void> setSessionActive(bool isActive) async {
    await _prefs?.setBool('is_session_active', isActive);
  }

  bool get isSessionActive => _prefs?.getBool('is_session_active') ?? false;

  // ── Intro Seen ──
  Future<void> setIntroSeen(bool seen) async {
    await _prefs?.setBool('intro_seen', seen);
  }

  bool get introSeen => _prefs?.getBool('intro_seen') ?? false;

  // ── Current User (active session user) ──
  Future<void> saveUser(UserModel user) async {
    await _prefs?.setString('user', jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final str = _prefs?.getString('user');
    if (str != null) return UserModel.fromJson(jsonDecode(str));
    return null;
  }

  // ── Registered Users (local user store) ──
  Future<void> registerUser(UserModel user) async {
    final users = getAllRegisteredUsers();
    // Prevent duplicates by email
    users.removeWhere((u) => u.email == user.email);
    users.add(user);
    final encoded = users.map((u) => jsonEncode(u.toJson())).toList();
    await _prefs?.setStringList('registered_users', encoded);
  }

  List<UserModel> getAllRegisteredUsers() {
    final strList = _prefs?.getStringList('registered_users') ?? [];
    return strList
        .map((str) => UserModel.fromJson(jsonDecode(str)))
        .toList();
  }

  UserModel? findUserByEmail(String email) {
    final users = getAllRegisteredUsers();
    try {
      return users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  // ── Profile ──
  Future<void> saveProfile(TravelerProfileModel profile) async {
    await _prefs?.setString('profile', jsonEncode(profile.toJson()));
  }

  TravelerProfileModel? getProfile() {
    final str = _prefs?.getString('profile');
    if (str != null) return TravelerProfileModel.fromJson(jsonDecode(str));
    return null;
  }

  // ── Favorites ──
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

  // ── Completed Routes ──
  Future<void> markRouteCompleted(String routeId) async {
    final list = getCompletedRoutes();
    if (!list.contains(routeId)) {
      list.add(routeId);
      await _prefs?.setStringList('completed_routes', list);
    }
  }

  Future<void> markRouteActive(String routeId) async {
    final list = getCompletedRoutes();
    if (list.contains(routeId)) {
      list.remove(routeId);
      await _prefs?.setStringList('completed_routes', list);
    }
  }

  List<String> getCompletedRoutes() {
    return _prefs?.getStringList('completed_routes') ?? [];
  }

  // ── Recent Searches ──
  Future<void> addRecentSearch(String query) async {
    final list = getRecentSearches();
    // Remove duplicates, keep most recent first
    list.remove(query);
    list.insert(0, query);
    // Keep only last 10
    final trimmed = list.take(10).toList();
    await _prefs?.setStringList('recent_searches', trimmed);
  }

  List<String> getRecentSearches() {
    return List<String>.from(_prefs?.getStringList('recent_searches') ?? []);
  }

  Future<void> clearRecentSearches() async {
    await _prefs?.setStringList('recent_searches', []);
  }
}
