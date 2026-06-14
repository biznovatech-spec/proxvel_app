# Reporte de Implementación: Fase 3C.2 — Flutter Secure Storage + ApiClient Interceptor

## 1. Resumen Ejecutivo
Se ha preparado el terreno técnico en el ecosistema Flutter para recibir y procesar el JWT desde el backend. Se integró la biblioteca estándar de almacenamiento seguro (`flutter_secure_storage`) y se modificó el cliente HTTP principal de la aplicación (`ApiClient`) para actuar como un interceptor pasivo. De este modo, cualquier futura mutación o lectura en el backend de FastAPI dispondrá de su Header `Authorization: Bearer <token>` adjunto automáticamente, preservando intacto el comportamiento de las APIs públicas mientras no exista un usuario logueado en la bóveda criptográfica del dispositivo.

## 2. Dependencia Agregada
Se añadió al archivo `pubspec.yaml`:
- `flutter_secure_storage: ^9.2.2`: El estándar actual para guardar información ultra confidencial (utiliza Keychain en iOS y EncryptedSharedPreferences en Android).

## 3. Archivos Modificados
- `pubspec.yaml`: Inclusión del paquete.
- `lib/integration/api/api_client.dart`: Interceptor de token asíncrono y control de la excepción `401`.
- `lib/controllers/auth_controller.dart`: Inyección de dependencias (`SecureTokenStorage`) y adición de firmas de funciones dummy preparatorias.
- `lib/app.dart`: Refactorización de la capa de inyección con `ProxyProvider` y `Provider` para surtir el nuevo servicio al cliente HTTP y al controlador.

## 4. Archivos Creados
- `lib/integration/local/secure_token_storage.dart`: Servicio proxy desacoplado que centraliza las operaciones I/O sobre el token.

## 5. Explicación de `SecureTokenStorage`
Se trata de una clase minimalista que encapsula la instancia inmutable de `FlutterSecureStorage`. Ofrece una API descriptiva de alto nivel para el resto del proyecto: `saveAccessToken(String token)`, `getAccessToken()`, `deleteAccessToken()` y `hasAccessToken()`. Se encuentra completamente aislado de `LocalStorageService`, garantizando la separación de responsabilidades.

## 6. Explicación del Cambio en `ApiClient`
Se transformó de una clase estática de solo parámetros HTTP a una estructura receptora. Ahora en cada método (`.get`, `.post`, `.put`, `.patch`), el cliente invoca previamente a `_getHeaders()`. Si detecta un token guardado, añade `Authorization: Bearer <token>`. Adicionalmente, el método `_decode(response)` fue alterado para atrapar nativamente el status `401 Unauthorized` y abortar la ejecución lanzando `ApiException(401, 'Sesión expirada o no autorizada.')`.

## 7. Confirmación de Almacenamiento
**Confirmado**: El Access Token, una vez lo capturemos del backend en la siguiente fase, será redirigido por el `AuthController` estrictamente a `_secureStorage.saveAccessToken(...)`.

## 8. Confirmación de `SharedPreferences`
**Confirmado**: El servicio obsoleto e inseguro `SharedPreferences` se conservó intacto en `LocalStorageService` únicamente para metadatos, banderas de Intro y caché visual inofensiva (`UserModel`). El JWT en ningún momento roza dicho almacenamiento.

## 9. Confirmación del Interceptor (Header Bearer)
**Confirmado**: El interceptor añade dinámicamente:
```json
{
  "Authorization": "Bearer <token_leido_de_la_boveda>"
}
```

## 10. Confirmación de Flujos Públicos
**Confirmado**: El código `_getHeaders()` fue diseñado a prueba de nulos. Si el token es devuelto como `null` o vacío por `flutter_secure_storage`, la inyección de `Authorization` se cancela de forma silente, permitiendo que la App solicite el catálogo `GET /destinations` de manera anónima y transparente.

## 11. Confirmación Visual
**Confirmado**: No se conectó ni modificó nada del `LoginScreen`. El botón sigue disparando el mensaje estático "Próximamente" para evitar disrupciones en la vista del usuario mientras ensamblamos la capa media de `Provider`.

## 12. Confirmación de Backend
**Confirmado**: No se alteró una sola línea del ecosistema Python/FastAPI.

## 13. Confirmación de Protección de Rutas
**Confirmado**: FastAPI sigue en su estado basal de la Fase 3C.1 (Desprotegido y permisivo), tal y como se requirió.

## 14. Resultado de Comandos (Pub Get)
**Confirmado**: El comando `flutter pub get` descargó los bindings en C++, Kotlin y Swift, actualizando `21 dependencias` exitosamente con Exit Code: 0.

## 15. Resultado de Comandos (Analyze)
**Confirmado**: El compilador de Dart se pronunció a favor:
`No issues found! (ran in 11.0s)` - `Exit code: 0`.

## 16. Riesgos Pendientes
- Al haber inyectado `SecureTokenStorage` en la raíz de la app (`app.dart`), si el dispositivo objetivo (ej: emuladores antiguos sin Lock Screen) no tiene hardware-backed keystore o un pin/patrón configurado, la librería `flutter_secure_storage` podría provocar una excepción silenciosa o crash en la primera escritura en ciertos OS viejos (Android < 6). Aunque no es frecuente en setups actuales.
- El Error 401 todavía se estrella como `ApiException` cruda. Si un view llama a un API endpoint y recibe un 401, aparecerá un error técnico rojo en consola/snack, pero aún no redirige a la pantalla de Login porque esto toca en la **Fase 3C.4**.

## 17. Conclusión
**Fase 3C.2 cerrada exitosamente.** La cañería y la arquitectura interceptora del JWT están listas para interconectar el UI del `LoginScreen`.
