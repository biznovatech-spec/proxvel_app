# Reporte de Auditoría: Fase 3B.6A — Mocks y LocalStorage

## 1. Archivos donde aparece `U00001`
- `lib/integration/api/api_config.dart` (Línea 13)

## 2. Archivos donde aparece `demoUserId`
- `lib/integration/api/api_config.dart` (Definición de la constante)
- `lib/integration/services/destination_service.dart` (Usado en `getDestinations` como fallback de query params para el ranking)
- `lib/integration/services/profile_service.dart` (Usado en el método `getUser()` en la carga legacy de perfiles sin sesión)
- `lib/integration/services/recommendation_service.dart` (Usado en fallback de peticiones de recomendaciones)

## 3. Métodos LocalStorage Existentes
1. `init()`
2. `isSessionActive()` / `setSessionActive()`
3. `hasSeenIntro()` / `setIntroSeen()`
4. `saveUser()` / `getUser()`
5. `registerUser()` / `getAllRegisteredUsers()` / `findUserByEmail()`
6. `saveProfile()` / `getProfile()`
7. `addFavorite()` / `removeFavorite()` / `getFavorites()`
8. `markRouteCompleted()` / `markRouteActive()` / `getCompletedRoutes()`
9. `addRecentSearch()` / `getRecentSearches()` / `clearRecentSearches()`

## 4. Métodos LocalStorage que SIGUEN SIENDO NECESARIOS
- Caché de Sesión Temporal: `init()`, `isSessionActive()`, `setSessionActive()`, `saveUser()`, `getUser()`, `saveProfile()`, `getProfile()`. (Indispensables mientras no exista un flujo robusto de JWT/SecureStorage).
- Variables de UX Global: `hasSeenIntro()`, `setIntroSeen()`.
- Módulos Offline/No Migrados: `addFavorite()`, `removeFavorite()`, `getFavorites()`, `markRouteCompleted()`, `markRouteActive()`, `getCompletedRoutes()`, `addRecentSearch()`, `getRecentSearches()`, `clearRecentSearches()`.

## 5. Métodos LocalStorage MUERTOS o DUPLICADOS
- `registerUser()`, `getAllRegisteredUsers()`, `findUserByEmail()`: Están **completamente muertos**. Con la Fase 3B.2, el registro y búsqueda de correos pasó a ser un flujo exclusivo del backend (`/api/v1/auth/register` y la base de datos de PostgreSQL). 

## 6. Lista de Mocks Existentes
- `lib/integration/mock/mock_aspect_data_source.dart`
- `lib/integration/mock/mock_destination_data_source.dart`
- `lib/integration/mock/mock_recommendation_data_source.dart`
- `lib/integration/mock/mock_route_data_source.dart`
- Funciones fake en `ProfileService` (`getDemoUsers`)

## 7. Mocks que SIGUEN SIENDO NECESARIOS
- `mock_route_data_source.dart`: El backend de Rutas todavía no está implementado en FastAPI.
- Mocks de destinos y aspectos: Siguen siendo útiles como salvavidas de red (fallbacks visuales de sólo lectura si el backend tarda en responder).

## 8. Mocks que YA NO DEBERÍAN SER FUENTE PRINCIPAL
- Inyección de `demoUserId` en `ProfileService.getUser()` y `ProfileController`: El fallback en `ProfileController` que dice *"Fallback a lógica antigua / demo si no hay usuario real"* mezcla la experiencia de un usuario deslogueado dándole de forma silenciosa el perfil demo en vez de pedirle que inicie sesión.

## 9. Riesgos de Eliminación
- **Eliminar `registerUser()`/`findUserByEmail()`/`getAllRegisteredUsers()` en LocalStorage:** *Riesgo nulo*. El `AuthController` ahora llama a la API.
- **Eliminar inyección de `demoUserId` en `ProfileService/Controller`:** *Riesgo Bajo/Medio*. Provocará que el frontend reaccione como realmente debe si un usuario entra "deslogueado" (perfil vacío pidiendo registro) en vez de fingir ser `U00001`.
- **Eliminar `mock_route_data_source.dart`:** *Riesgo Alto*. Rompería la sección de Rutas.

## 10. Recomendación Exacta para 3B.6B
**Solo se deben realizar las siguientes cirugías limpias:**
1. **`local_storage_service.dart`**: Eliminar `registerUser()`, `getAllRegisteredUsers()` y `findUserByEmail()`.
2. **`profile_controller.dart`**: Limpiar la rama del if/else que fuerza el perfil mock/local a los usuarios que no tienen un ID que empiece con `U000...`. Si no hay usuario real validado en caché, `user` y `profile` quedan nulos y muestran la pantalla de Login (o estado vacío).
3. **`profile_service.dart`**: Retirar el parche de red que usa `/users/${ApiConfig.demoUserId}` dentro del viejo método `getUser()`.

## 11. Conformidad de Modificaciones en Código
- **Confirmado**: No se realizó ninguna alteración de código en el proyecto Flutter durante la auditoría.
- **Confirmado**: `flutter analyze` permanece intocado con 0 issues.

## 12. Conformidad Backend
- **Confirmado**: No se tocó, inspeccionó, modificó ni reinició el entorno de FastAPI/PostgreSQL.
