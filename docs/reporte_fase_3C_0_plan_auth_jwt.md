# Reporte de Plan Técnico: Fase 3C.0 — Login/JWT Real

## 1. Resumen Ejecutivo
Este documento despliega la auditoría y estrategia técnica para la migración arquitectónica final de autenticación en PROXVEL, pasando de simulaciones pre-JWT y cachés transaccionales temporales hacia un estándar de la industria robusto y state-less basado en **JSON Web Tokens (JWT)**. Este plan establece el protocolo para proteger las rutas sin romper la estabilidad demostrativa que ya hemos ganado.

## 2. Estado Actual del Login
Actualmente, el inicio de sesión en Flutter (a través de `LoginScreen` y `AuthController.login`) se encuentra desconectado. Devuelve un mensaje simulado ("El inicio de sesión real estará disponible próximamente.") debido a la reciente extirpación del `LocalStorageService` legacy que gestionaba perfiles locales de mentira. No hay interacción con el backend durante este flujo.

## 3. Estado Actual del Registro
El registro en Flutter opera positivamente y es transaccional hacia el backend a través del endpoint general `POST /api/v1/users`, en la ruta `user_routes.py`. FastAPI lo procesa y guarda un usuario en la tabla `users` mediante PostgreSQL.

## 4. Estado Actual del Hash de Contraseña
El backend almacena las contraseñas hasheadas en el campo `password_hash`. FastAPI emplea actualmente `hashlib.pbkdf2_hmac('sha256', ...)` configurado en `app/utils/hash_util.py`. El sistema genera de forma autóctona validaciones usando la función `verify_password`.

## 5. Endpoints de Auth Existentes
**Ninguno**. No existe un router dedicado a autenticación (`auth_routes.py`), ni hay endpoints de login que expidan un Bearer token. La aplicación actual asume en el backend que cualquiera que sepa un `user_id` puede alterar sus perfiles.

## 6. Endpoints de Auth Faltantes
Se debe crear un router `app/routes/auth_routes.py` que exponga:
- `POST /api/v1/auth/login`: Para recibir credenciales y devolver el Access Token JWT.
- `GET /api/v1/auth/me`: Para que el frontend consulte el perfil asociado al Token proporcionado, re-hidratando la sesión en el reinicio de la app.
- `POST /api/v1/auth/logout`: (Opcional por si requiere blacklistear o limpiar recursos en BD si es stateful).

## 7. Cambios Necesarios en Backend
1. Instalar librerías de gestión JWT: `PyJWT` o `python-jose` en `requirements.txt`.
2. Crear un módulo `app/core/security.py` conteniendo funciones como `create_access_token` y las constantes `SECRET_KEY`, `ALGORITHM` (HS256) y `ACCESS_TOKEN_EXPIRE_MINUTES`.
3. Crear un interceptor/dependency `get_current_user` usando `OAuth2PasswordBearer` de FastAPI para extraer, desencriptar el JWT y obtener el `user_id`.
4. Añadir `auth_routes.py` y enrutarlo en `main.py`.

## 8. Cambios Necesarios en Flutter
1. El `LoginScreen` debe conectar con el método `login` de `AuthController`, el cual ahora invocará a `ApiClient.post('/auth/login', ...)`.
2. Las peticiones a la API desde `AuthService` (nuevo) y `UserService` deben integrar control de errores 401.
3. Actualizar `RegisterScreen` para que redirija al login o lo auto-loguee pasándole un token en cascada.

## 9. Estrategia de Almacenamiento Seguro
Añadir el paquete oficial de Dart `flutter_secure_storage`. Tras un login exitoso, el string largo del Access Token se inyectará en esta bóveda cifrada en lugar del inseguro `SharedPreferences`.

## 10. Estrategia de Interceptor HTTP
Modificar el archivo `lib/integration/api/api_client.dart` de Flutter. Se le inyectará una lectura al `flutter_secure_storage`. Si existe un token, toda llamada `.get`, `.post`, `.patch` o `.put` anexará por inyección a la fuerza el header `Authorization: Bearer <token_real>`.

## 11. Estrategia de Restauración de Sesión
Dentro del archivo de entrada o en el `init()` principal:
1. Extraer el token de `flutter_secure_storage`.
2. Si existe, enviar petición silente a `/api/v1/auth/me`.
3. Si responde 200, cargar el `currentUser` en RAM y saltar directo a `MainScreen` saltándose el Login/Onboarding.

## 12. Estrategia de Logout
El método `logout` limpiará el token del `Secure Storage` y reseteará los Controllers al estado nulo inicial, devolviendo visualmente al usuario a la pantalla de bienvenida.

## 13. Endpoints que Deben Protegerse Primero (Sensibles)
- `PUT /users/{user_id}/traveler-profile`
- `PATCH /users/{user_id}/traveler-profile`
- `POST /reviews`
Estos métodos realizan mutaciones en cascada y escriben en la base de datos, por lo que es vital frenar el secuestro de sesiones.

## 14. Endpoints que NO Deben Protegerse Aún (Públicos)
- `GET /destinations` y `GET /destinations/{id}`
- `GET /tourism-catalog`
- `GET /recommendations`
Los datos pasivos y catálogos pueden consultarse offline o mientras el usuario no esté logueado como parte de un modelo "freemium" u "observador" en las pantallas principales.

## 15. Riesgos Técnicos
- **Desincronización por 401 No Manejado:** Si el token expira pero Flutter no está preparado para interceptar el status 401 para redireccionar al login de forma transparente, el usuario se topará con un loop de UI o una pantalla en blanco.
- **Romper Compatibilidad Hash:** Si instalamos Passlib para usar algoritmos como bcrypt, podría no ser compatible con el hash experimental actual en PBKDF2. Conviene integrar los tokens pero dejar `hash_util.py` con PBKDF2 sin migraciones estresantes de datos pasados.

## 16. Plan Dividido por Subfases (Recomendado)
- **Fase 3C.1**: Backend Auth JWT (Instalar libs, dependencias, rutas de Auth en FastAPI, sin proteger los otros todavía).
- **Fase 3C.2**: Flutter Secure Storage e Interceptor (Añadir plugin, configurar ApiClient).
- **Fase 3C.3**: LoginScreen conectado a Backend (Flujo Login, errores y guardado de Bearer).
- **Fase 3C.4**: Logout y Restauración de Sesión (On Startup: `GET /auth/me`).
- **Fase 3C.5**: Protección Gradual Backend (Meter `get_current_user` en Perfiles y Reviews y probar validación 401).
- **Fase 3C.6**: Validación E2E Auth Completa.

## 17. Recomendación para Iniciar 3C.1
Para arrancar, es vital enfocarnos al 100% en el backend: Instalar las dependencias JWT (`python-jose`) en `requirements.txt` y programar los endpoints de auth (`/login` y `/me`) de tal forma que nos devuelvan el Bearer Token por Postman. 

## 18. Confirmación de Código
**Confirmado**: NO se ha insertado ni extraído una sola letra de código en el ecosistema real. Solo lectura en el IDE.

## 19. Confirmación de Base de Datos
**Confirmado**: NO se ejecutó ningún impacto, query ni mutación transaccional sobre PostgreSQL.

## 20. Confirmación de JWT
**Confirmado**: NO se implementó lógica técnica ni práctica de JWT por el momento. La fase es 100% de planificación diagnóstica.
