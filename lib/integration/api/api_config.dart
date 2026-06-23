/// Configuración central de la API PROXVEL.
///
/// `10.0.2.2` es el alias del host (localhost de tu PC) visto desde
/// el emulador Android. Para dispositivo físico usar la IP LAN de la PC.
library;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get _fallbackUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1';
    // iOS Simulator y Desktop
    return 'http://127.0.0.1:8000/api/v1';
  }

  static String get baseUrl {
    if (bool.hasEnvironment('API_BASE_URL')) {
      return const String.fromEnvironment('API_BASE_URL');
    }
    return _fallbackUrl;
  }

  static const String webBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const int timeoutSeconds = 8;

  static const bool useMockFallback = bool.fromEnvironment(
    'USE_MOCK_FALLBACK',
    defaultValue: false,
  );

  // Endpoints
  static const String favorites = '/favorites';

  static String get apiBaseUrl => baseUrl;
}
