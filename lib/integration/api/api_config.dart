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
    // `bool.hasEnvironment` NO está soportado en Flutter Web (lanza
    // "Unsupported operation"). Se lee directamente con String.fromEnvironment
    // (const, web-safe) y se usa el fallback si no fue definido en el build.
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return _fallbackUrl;
  }

  static const String webBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const int timeoutSeconds = 30;

  static const bool useMockFallback = bool.fromEnvironment(
    'USE_MOCK_FALLBACK',
    defaultValue: false,
  );

  // Endpoints
  static const String favorites = '/favorites';

  static String get apiBaseUrl => baseUrl;
}
