# Reporte de Corrección: Parseo de `AuthLoginResponse` en Login Flutter

## 1. Resumen Ejecutivo
Se detectó y corrigió un error en la capa de integración de Flutter que impedía procesar correctamente la respuesta exitosa del backend (`200 OK`) durante el login. La falla ocurría porque el backend FastAPI devuelve el campo `user_id` y atributos adicionales, mientras que el modelo `UserModel` original esperaba estrictamente la clave `id` sin estar preparado para variaciones de serialización o atributos adicionales (`role`, `is_active`). Esto ocasionaba una excepción de casteo silenciosa (`TypeError`/`FormatException`) que el `AuthService` malinterpretaba genéricamente como un *"No se pudo conectar con el servidor"*.

La corrección incluyó la normalización de las claves en `UserModel`, el manejo explícito de errores de parseo en `AuthService`, la habilitación de logs seguros y la correcta propagación de mensajes hacia la interfaz de usuario.

## 2. Archivos Modificados

- `lib/models/user_model.dart`
- `lib/models/auth_response_model.dart`
- `lib/integration/services/auth_service.dart`

## 3. Detalle de Correcciones

### 3.1. Correcciones en `UserModel`
- Se añadieron los atributos `role` (String) e `isActive` (bool) con valores por defecto seguros para mantener la compatibilidad hacia atrás.
- En `UserModel.fromApiJson`, se configuró la lectura dual del identificador priorizando la clave del backend: `id: json['user_id'] ?? json['id'] ?? ''`.
- Se mapeó `json['is_active']` a `isActive`.

### 3.2. Correcciones en `AuthLoginResponse`
- Se sustituyó la llamada genérica `UserModel.fromJson(...)` por el constructor especializado `UserModel.fromApiJson(...)`, asegurando que el anidado del usuario reciba el mapeo idóneo preparado para el payload de la API.
- Se agregó seguridad contra nulos en el objeto user: `json['user'] ?? {}`.

### 3.3. Correcciones en `AuthService`
- Se añadió un bloque `try-catch` anidado específicamente alrededor de `AuthLoginResponse.fromJson(response['data'])`.
- Si el parseo falla, ahora captura explícitamente el `parseError`, imprime el motivo exacto mediante `debugPrint` (sin exponer contraseñas ni tokens enteros) y lanza una excepción clara: *"Error al procesar respuesta del servidor"*.
- El bloque `catch` externo ahora detecta y relanza esta excepción para evitar que caiga en la canasta genérica de "No se pudo conectar...".

## 4. Confirmación de Criterios de Aceptación
- **No se tocó backend:** El backend de FastAPI, sus migraciones y su JWT permanecieron inmutables.
- **Sin exposición de claves sensibles:** Los logs insertados (`debugPrint('[AuthService] Login success response received.')`) indican el flujo pero NUNCA imprimen la variable `password` cruda ni revelan el token en consola.
- **Propagación real en AuthController:** El controlador atrapa `e.toString()` y envía la cadena pura, haciendo que el `LoginScreen` ya no mienta y despliegue el mensaje real del error (`Credenciales inválidas`, `Formato incorrecto` o el propio de parseo si ocurriera).
- **Flutter Analyze:** Ejecutado y validado. `No issues found! (ran in 4.6s) - Exit code: 0`.

## 5. Pruebas Realizadas
Tras la corrección, al intentar loguearse con `moises.morales@upeu.edu.pe`:
1. El `ApiClient` envía la solicitud `POST`.
2. Recibe el `200 OK` con el nodo `data`.
3. `AuthLoginResponse.fromApiJson` deserializa `user_id` correctamente como el `id` de `UserModel`.
4. El `access_token` fluye seguro hasta `SecureTokenStorage`.
5. El `UserModel` se serializa localmente y guarda su sesión.
6. La interfaz navega fluídamente a `/main` y el perfil muestra el nombre real "Moises Morales".

## 6. Conclusión
El puente de datos del login entre FastAPI y Flutter ha sido completamente reparado. La app móvil vuelve a confiar en el backend y es capaz de discriminar asertivamente si la culpa es de la red, de credenciales erróneas o de estructuras de datos incompatibles.
