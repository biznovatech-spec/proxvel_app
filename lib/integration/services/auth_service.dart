import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../../models/auth_response_model.dart';
import '../../models/user_model.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  Future<AuthLoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
      );

      debugPrint('[AuthService] Login success response received.');

      if (response['success'] == true && response['data'] != null) {
        try {
          return AuthLoginResponse.fromJson(response['data']);
        } catch (parseError) {
          debugPrint('[AuthService] Error parsing login response: $parseError');
          throw Exception('Error al procesar respuesta del servidor.');
        }
      }
      throw Exception(response['message'] ?? 'Error desconocido en login');
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 401) {
          throw Exception(e.message);
        } else if (e.statusCode == 422) {
          throw Exception('Correo inválido o formato incorrecto.');
        }
        throw Exception('Error del servidor: ${e.statusCode}');
      }
      if (e.toString().contains('Error al procesar respuesta')) {
        rethrow;
      }
      throw Exception('No se pudo conectar con el servidor.');
    }
  }

  Future<UserModel> me() async {
    try {
      final response = await apiClient.get('/auth/me');
      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Error desconocido al validar sesión');
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        throw Exception('Sesión expirada o no autorizada.');
      }
      rethrow;
    }
  }
}
