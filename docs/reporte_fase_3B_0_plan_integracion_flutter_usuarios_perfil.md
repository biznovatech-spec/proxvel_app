# Reporte de Planificación: Fase 3B.0 — Integración Flutter con Backend Real

## 1. Resumen Ejecutivo
Este documento traza la ruta técnica para conectar progresivamente el frontend (Flutter) con los endpoints MVP construidos en el backend en la Fase 3A. El objetivo principal es que el registro de usuarios y el onboarding dejen de depender del almacenamiento local para pasar a usar PostgreSQL como fuente única de la verdad, reemplazando paralelamente los *fallbacks* temporales como `U00001`.

## 2. Estado actual del frontend
Actualmente, `proxvel_app` opera de forma híbrida: consulta destinos y reseñas desde el backend (`GET /destinations`, `POST /reviews`), pero la creación de usuarios y perfiles ocurre 100% en el dispositivo usando `SharedPreferences` a través de `LocalStorageService`. Además, la app inyecta de forma dura el ID `U00001` cuando requiere enviar una reseña o consultar el historial, debido a la ausencia previa de usuarios reales.

## 3. Archivos analizados
Se revisaron en profundidad los siguientes archivos del frontend:
- **Controladores:** `auth_controller.dart`, `onboarding_controller.dart`, `profile_controller.dart`, `my_reviews_controller.dart`.
- **Servicios:** `local_storage_service.dart`, `profile_service.dart`, `api_config.dart`.
- **Vistas:** `feedback_screen.dart`.

## 4. Clasificación de Dependencias Locales (`LocalStorageService`)

| Elemento | Archivo | Uso actual | Backend que lo reemplaza | Riesgo | Acción recomendada |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `registerUser`, `getAllRegisteredUsers` | `local_storage_service.dart` | Fake DB de usuarios | `POST /api/v1/users` | Falla por correos duplicados | **A. Reemplazar en Fase 3B.1** |
| `saveProfile`, `getProfile` | `local_storage_service.dart` | Guardar preferencias | `PUT /traveler-profile` y `GET` | 404 si el usuario no existe en DB | **A. Reemplazar en Fase 3B.1** |
| `saveUser`, `getUser` | `local_storage_service.dart` | Cache del usuario activo en sesión | N/A (Solo será caché) | Desincronización con backend | **B. Mantener como caché** |
| `isSessionActive`, `introSeen` | `local_storage_service.dart` | Flags de estado de la app | N/A | Ninguno | **B. Mantener como caché** |
| Búsquedas recientes | `local_storage_service.dart` | Historial de búsqueda | N/A | Ninguno | **B. Mantener como caché** |
| Favoritos, Rutas completadas | `local_storage_service.dart` | Fake DB de favoritos y rutas | Nuevos endpoints (Fase 4) | Pérdida al limpiar caché | **C. Mantener como deuda futura** |
| Login local (`login`) | `auth_controller.dart` | Valida password contra Fake DB | `POST /auth/login` | No hay backend para esto aún | **C. Mantener como deuda futura** |

## 5. Lugares donde aparece el fallback `U00001`
Se identificaron 3 puntos críticos que deben eliminarse en la etapa de limpieza:
1. `lib/controllers/my_reviews_controller.dart`: En la línea 25 se fuerza `userId = 'U00001'` si no es backend user.
2. `lib/views/feedback/feedback_screen.dart`: En las líneas 193-197 se envía `U00001` al enviar la reseña.
3. `lib/integration/api/api_config.dart`: Existe la constante `static const String demoUserId = 'U00001';`.
**Clasificación:** **D. Eliminar después de validación de registro.**

## 6. Modelos Flutter a modificar
- **`UserModel`:** Deberá ajustarse el método `toJson` para unificar `name` y `lastName` (el backend solo espera `name`) y mapear correctamente la respuesta `UserResponse` del backend.
- **`TravelerProfileModel`:** Deberá ajustar su serialización para empatar 1 a 1 con los campos esperados por `TravelerProfileCreate` y `TravelerProfileUpdate` (ej. `budget_preference` a `presupuesto`, o mantener los nombres exactos definidos en Fase 3A).

## 7. Servicios Flutter a crear o modificar
- **`UserService` (Nuevo):** Encargado de hacer las peticiones `POST /api/v1/users` y `GET /api/v1/users/{user_id}` manejando los errores HTTP (ej. 409 Conflict).
- **`ProfileService` (Modificado):** Se redirigirá `saveProfile` a `PUT /api/v1/users/{user_id}/traveler-profile` y `getProfile` a su respectivo `GET`.

## 8. Controladores a modificar
- **`AuthController`:** Su método `register()` delegará la creación a `UserService` y guardará la respuesta real del backend (ej. `U00004`) en el caché local de sesión.
- **`OnboardingController`:** Su método `saveProfile()` delegará a `ProfileService` enviando el `user_id` real.
- **`ProfileController`:** Dejará de leer localmente y recargará los datos consultando los servicios de backend para asegurar frescura.

## 9. Pantallas afectadas
- **`RegisterScreen`:** Deberá manejar visualmente errores de red (ej. SnackBar para "El correo ya está registrado").
- **`OnboardingScreen`:** Podría tener un leve delay al guardar el perfil contra internet, requiriendo un indicador de carga.
- **`ProfileScreen` / `MyReviewsScreen`:** Pasarán a operar de manera nativa con usuarios generados orgánicamente.

## 10. Endpoints backend que consumirá Flutter
```text
POST   /api/v1/users
GET    /api/v1/users/{user_id}
GET    /api/v1/users/{user_id}/traveler-profile
PUT    /api/v1/users/{user_id}/traveler-profile
PATCH  /api/v1/users/{user_id}/traveler-profile
```

## 11. Riesgos
1. **Falta de Login Real:** Ya que no implementaremos `POST /auth/login` todavía, el login de la app no podrá validar la contraseña de los usuarios creados en el backend. Esto generará una deuda técnica donde el login deba simularse o bypassearse temporalmente.
2. **Correos Duplicados:** La app puede *crashear* si no se maneja explícitamente el código de estado 409 en el registro.
3. **Mapeo de Campos:** Diferencias entre el snake_case del backend y el camelCase de Dart podrían causar envío de valores nulos o 422 Unprocessable Entity.

## 12. Plan por Subfases
Se propone la siguiente ruta de ejecución ordenada:
- **Fase 3B.1 — Crear UserService y actualizar Modelos en Flutter:** Preparar las clases, mapeos JSON y métodos para consumir la API.
- **Fase 3B.2 — Conectar Registro y Onboarding:** Intervenir `AuthController` y `OnboardingController` para usar `POST /users` y `PUT /traveler-profile`.
- **Fase 3B.3 — Conectar Perfil (Lectura/Escritura):** Modificar `ProfileService` y `ProfileController` para cargar los datos en la pantalla de "Mi Cuenta" directo desde la red.
- **Fase 3B.4 — Eliminar Fallback U00001:** Purgar de manera segura las inyecciones de `U00001` en reseñas y feedback.

## 13. Qué NO se debe tocar todavía
- Autenticación formal con JWT.
- Integración de inicio de sesión real (password verification via backend).
- `FavoritesController` y `RoutesController` (mantenerlos locales).
- Cloudinary para subida de fotos de perfil.

## Confirmaciones de la Fase 3B.0
- [x] Confirmo que **NO se modificó código en Flutter**.
- [x] Confirmo que **NO se tocó el backend**.
- [x] Confirmo que **LocalStorage y los Mocks siguen intactos** en esta fase de análisis.
