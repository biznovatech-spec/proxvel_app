/// Configuración central de la API PROXVEL.
///
/// `10.0.2.2` es el alias del host (localhost de tu PC) visto desde
/// el emulador Android. Para dispositivo físico usar la IP LAN de la PC.
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  static const int timeoutSeconds = 8;

  /// Usuario demo de la tesis usado para el ranking contextual
  /// (los 3000 perfiles simulados de Fase 3 usan IDs U00001..U03000).
  static const String demoUserId = 'U00001';

  static String get apiBaseUrl => baseUrl;
}
