# Reporte de Cierre: Fase 3B.1 — Servicios y Modelos Flutter para Backend

## 1. Resumen Ejecutivo
Se implementó exitosamente la capa de integración en Flutter para preparar la conexión con los endpoints MVP de usuarios y perfiles viajeros desarrollados en la Fase 3A. Se ajustaron los modelos de datos para empatar exactamente con las firmas requeridas por PostgreSQL/FastAPI (snake_case) manteniendo la compatibilidad interna de Dart (camelCase), y se programaron los servicios HTTP para orquestar la comunicación. Todo esto, respetando la regla de no alterar la interfaz visual ni los controladores de la aplicación en esta fase preliminar.

## 2. Archivos Creados/Modificados
- **`lib/models/user_model.dart`** (Modificado)
- **`lib/models/traveler_profile_model.dart`** (Modificado)
- **`lib/integration/api/api_client.dart`** (Modificado)
- **`lib/integration/services/user_service.dart`** (Creado)
- **`lib/integration/services/profile_service.dart`** (Modificado)

## 3. Cambios en Modelos
### `UserModel`
Se añadió el método `toApiJson()`. Debido a que el backend únicamente contempla un campo unificado `name` y la app maneja `name` y `lastName`, la función se encarga de concatenarlos limpiamente antes de enviar la petición (por ejemplo: `$name $lastName`). Además, mapea el campo estricto `email` y `password` para los registros, sin enviar atributos no reconocidos ni hashes.

### `TravelerProfileModel`
Se integraron explícitamente los 10 campos de "peso" (ej. `peso_seguridad`, `peso_costos`, etc.) como variables `double` y se estableció `3.0` como valor por defecto.
Se añadieron los métodos `fromApiJson()` y `toApiJson()`, los cuales:
1. Traducen los atributos en `snake_case` (ej. `budget_preference`) al equivalente local interno.
2. Fuerzan a que los pesos se empaqueten dentro de los límites estrictos con `.clamp(1.0, 5.0)` para garantizar que el WSM del backend no reciba anomalías estadísticas.

## 4. Servicios HTTP Integrados
### `ApiClient`
Se expandió su funcionalidad agregando los métodos HTTP `put()` y `patch()`, los cuales decodifican la respuesta JSON o arrojan `ApiException` en caso de error.

### `UserService` (Nuevo)
Se crearon las funciones asíncronas para el manejo de cuentas:
- `createUser(name, email, password)` → *POST /api/v1/users*
- `getUserById(userId)` → *GET /api/v1/users/{user_id}*
- `updateUser(userId, name, password)` → *PATCH /api/v1/users/{user_id}*

### `ProfileService`
Se implementaron las operaciones CRUD específicas del perfil dentro de `ProfileService`:
- `getTravelerProfile(userId)` → *GET /api/v1/users/{user_id}/traveler-profile*
- `putTravelerProfile(...)` → *PUT /api/v1/users/{user_id}/traveler-profile*
- `patchTravelerProfile(...)` → *PATCH /api/v1/users/{user_id}/traveler-profile*

## 5. Manejo de Errores Implementado
Ambos servicios cuentan con manejadores de excepciones por código de estado. Se interceptan y traducen amigablemente:
- **`409`** en Registro: Lanza "El correo electrónico ya está registrado."
- **`404`** en Perfil/Usuario: Lanza "Usuario/Perfil no encontrado."
- **`422`**: Identificado y mapeado a "Error de validación".

## 6. Confirmaciones de Restricciones
- [x] **Controladores intactos:** `AuthController`, `OnboardingController` y `ProfileController` no se modificaron.
- [x] **Pantallas intactas:** No se intervino el flujo visual ni el enrutamiento.
- [x] **Mocks/Locals:** El `LocalStorage` se mantiene funcional; el ID temporal `U00001` no ha sido borrado todavía.
- [x] **Backend intacto:** Todos los cambios fueron exclusivos del proyecto Flutter.
- [x] **Compilación Limpia:** `flutter analyze` reporta **0 issues found**.

## 7. Deuda Técnica Restante (Próximas Fases)
Con las herramientas listas en código, el proyecto está preparado para avanzar hacia las conexiones lógicas:
1. Conectar la pantalla visual de Registro para que active `UserService.createUser`.
2. Conectar la pantalla del Onboarding para que guarde el test de preferencias mediante `ProfileService.putTravelerProfile`.
3. Cargar dinámicamente el Perfil de Viajero real desde internet en `ProfileScreen`.
4. Extirpar definitivamente el uso de `U00001`.
5. Implementar formalmente JWT y `/auth/login` (Fase 3D).
