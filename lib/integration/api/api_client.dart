import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../local/secure_token_storage.dart';

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
  static Function()? onUnauthorized;
  static Function(String)? onForbidden;

  final http.Client _http;
  final SecureTokenStorage _secureStorage;

  ApiClient({http.Client? httpClient, SecureTokenStorage? secureStorage}) 
      : _http = httpClient ?? http.Client(),
        _secureStorage = secureStorage ?? SecureTokenStorage();

  Future<Map<String, String>> _getHeaders({bool isGet = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (!isGet) {
      headers['Content-Type'] = 'application/json';
    }
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    var uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    debugPrint('[API] GET $uri');
    final headers = await _getHeaders(isGet: true);
    final response = await _http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(response);
  }

  Future<dynamic> post(String endpoint, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    debugPrint('[API] POST $uri');
    final headers = await _getHeaders();
    final response = await _http
        .post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(response);
  }

  Future<dynamic> put(String endpoint, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    debugPrint('[API] PUT $uri');
    final headers = await _getHeaders();
    final response = await _http
        .put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(response);
  }

  Future<dynamic> patch(String endpoint, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    debugPrint('[API] PATCH $uri');
    final headers = await _getHeaders();
    final response = await _http
        .patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    debugPrint('[API] DELETE $uri');
    final headers = await _getHeaders();
    final response = await _http
        .delete(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(response);
  }

  Future<dynamic> postMultipart(
    String endpoint, {
    required String filePath,
    required String fileField,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    debugPrint('[API] POST MULTIPART $uri');
    
    final request = http.MultipartRequest('POST', uri);
    
    // Añadir headers de autenticación
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Añadir el archivo
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    
    // Enviar y esperar
    final streamedResponse = await request
        .send()
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds * 2)); // Doble tiempo para subidas
        
    final response = await http.Response.fromStream(streamedResponse);
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode == 401) {
      onUnauthorized?.call();
      throw ApiException(401, 'Tu sesión expiró. Inicia sesión nuevamente.');
    }
    if (response.statusCode == 403) {
      final message = 'No tienes permiso para realizar esta acción.';
      onForbidden?.call(message);
      throw ApiException(403, message);
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is Map<String, dynamic> && json.containsKey('success') && json['success'] == false) {
        throw ApiException(response.statusCode, json['message'] ?? 'Error desconocido de la API');
      }
      return json;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
