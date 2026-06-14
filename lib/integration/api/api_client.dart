import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Error de la API PROXVEL (4xx/5xx o respuesta inválida).
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Cliente HTTP del backend PROXVEL.
///
/// Todos los servicios lo usan con el patrón API-first + fallback mock:
/// si la petición falla (backend apagado, timeout, error), el servicio
/// captura la excepción y continúa con datos locales.
class ApiClient {
  final http.Client _http;
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    var uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    debugPrint('[API] GET $uri');
    final response = await _http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    debugPrint('[API] POST $uri');
    final response = await _http
        .post(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    debugPrint('[API] PUT $uri');
    final response = await _http
        .put(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(response);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    debugPrint('[API] PATCH $uri');
    final response = await _http
        .patch(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException(response.statusCode, response.body);
  }
}
