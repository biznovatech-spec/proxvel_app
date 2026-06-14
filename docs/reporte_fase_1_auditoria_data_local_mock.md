# Fase 1: Reporte de Auditoría y Clasificación de Data Local/Mock en PROXVEL App

## 1. Objetivo de la auditoría
Identificar, clasificar y documentar el uso actual de datos locales y mocks en el frontend (Flutter) de la aplicación PROXVEL. El propósito es preparar el terreno para la Fase 2, donde la aplicación dejará de depender de datos "quemados" como fuente principal y pasará a consumir los endpoints reales del backend FastAPI + PostgreSQL, sin eliminar prematuramente configuraciones locales legítimas (como estado de onboarding o caché temporal).

## 2. Resumen ejecutivo
La aplicación se encuentra en un estado "híbrido". Actualmente, servicios clave como `DestinationService`, `RecommendationService` y `ProfileService` tienen lógica `API-first` que intenta conectar con el backend y utiliza mocks como fallback. Sin embargo, otras funcionalidades críticas como el **Catálogo General (Explorar)**, la **Creación de Reseñas** y la **Edición de Perfil** están completamente desconectadas del backend y usan data local (`MockDestinationDataSource` y `LocalStorageService`) como fuente *única* y principal de la verdad.

## 3. Archivos analizados
Se revisaron exhaustivamente:
* `lib/integration/mock/*` (4 archivos)
* `lib/integration/local/local_storage_service.dart`
* `lib/integration/services/*` (5 servicios principales)
* `lib/integration/api/api_client.dart`
* `lib/views/*` (Feedback, Profile, Destination, Home, Search, ForYou)

## 4. Servicios que usan backend real (Parcialmente)
* **`DestinationService`**: Usa `GET /destinations/{id}` para obtener el detalle de un destino (clima, aforo, aspect scores) y `GET /recommendations/contextual` para la explicación final.
* **`ProfileService`**: Usa `GET /users/demo` y `GET /users/{user_id}` para obtener el perfil del usuario activo al iniciar.
* **`RecommendationService`**: Usa `GET /recommendations/contextual` para la pantalla "Para ti".

## 5. Servicios que aún usan mock/local como fuente principal
* **`DestinationService`**: El método `getDestinations()` devuelve estáticamente `MockDestinationDataSource.activeDestinations`.
* **`FeedbackService`**: El método `submitFeedback()` solo guarda en el celular usando `LocalStorageService`.
* **`ProfileService`**: El método `saveProfile()` solo guarda las preferencias de viaje en el celular.
* **`RouteService`**: Rutas turísticas completamente mockeadas.

## 6. Vistas conectadas a backend
* **`DestinationDetailScreen`**: Conectada. Renderiza scores reales del backend (clima, multitudes, ABSA).
* **`ForYouScreen`**: Conectada. Renderiza las recomendaciones con el porcentaje de compatibilidad de la IA.
* **Login/Selección de Perfil**: Conectada. Muestra la lista de usuarios de `GET /users/demo`.

## 7. Vistas desconectadas o con data local
* **`HomeScreen`** (Explorar): Desconectada. Muestra la lista quemada en `MockDestinationDataSource`.
* **`FeedbackScreen`**: Desconectada. Crea reseñas pero se quedan en el teléfono.
* **`EditProfileScreen`**: Desconectada. Las preferencias de viaje se quedan en el teléfono.
* **`FavoritesScreen`**: Desconectada. Usa `LocalStorageService` (no hay endpoint backend de favoritos aún).
* **`SearchResultsScreen`**: Búsquedas recientes mockeadas o locales.

## 8. Carpeta Mock: Archivo por archivo

| Archivo Mock | Qué datos contiene | Usado por | Endpoint equivalente | ¿Conservar fallback? | Riesgo de eliminar hoy |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `mock_destination_data_source.dart` | 11 destinos completos (fotos, textos). | `HomeScreen`, `DestinationService` | `GET /destinations` | **SÍ** | Rompe el catálogo general porque la app no llama a `/destinations` todavía. |
| `mock_aspect_data_source.dart` | Scores inventados por destino. | `DestinationDetail` (fallback) | `GET /destinations/{id}` | NO | Mostraría datos irreales que confunden las pruebas de tesis. Eliminar pronto. |
| `mock_recommendation_data_source.dart` | 3 destinos sugeridos. | `ForYouScreen` | `GET /recommendations/contextual` | **SÍ** | La pantalla Para Ti quedaría vacía si el backend de FastAPI no responde. |
| `mock_route_data_source.dart` | Rutas turísticas ("Ruta Inca Mágica"). | `RouteService` | N/A | NO | Ninguno si la vista de Rutas no es crítica. No hay backend de esto. |

## 9. Análisis de `LocalStorageService`

| Método | Qué guarda | ¿Buena práctica? | ¿Reemplazar por Backend? | Acción recomendada |
| :--- | :--- | :--- | :--- | :--- |
| `init() / registerUser()` | Crea un usuario dummy al abrir la app. | No para prod, sí para dev. | SÍ (Login/JWT futuro) | Mantener temporal, pero no como registro final. |
| `setSessionActive()`, `setIntroSeen()` | Flags de sesión y onboarding. | **SÍ** | NO | **Conservar definitivamente.** |
| `saveUser()`, `getUser()` | Caché del usuario logueado. | **SÍ** | NO (es caché válido) | **Conservar como sesión activa local.** |
| `getAllRegisteredUsers()` | Simulador de base de datos de usuarios. | NO | SÍ | Reemplazar por autenticación real. |
| `saveProfile()`, `getProfile()` | Formulario del viajero (preferencias). | NO | SÍ (`PUT /users/{id}`) | Backend debe implementarlo, luego reemplazar. |
| `addFavorite()`, `getFavorites()` | Destinos guardados. | NO (debería ser nube) | SÍ (endpoint futuro) | Reemplazar cuando exista endpoint. |
| `markRouteCompleted()` | Simulador de rutas jugadas. | NO | SÍ (endpoint futuro) | Reemplazar o deshabilitar. |
| `saveFeedback()`, `getFeedbackList()`| Reseñas guardadas. | NO | **SÍ (`POST /reviews`)** | **Reemplazo inmediato en Fase 2.** |
| `addRecentSearch()` | Historial de búsquedas recientes. | **SÍ** | NO (opcional) | **Conservar como caché válido.** |

## 10. Data local que se debe CONSERVAR (Categoría A)
* Estado de onboarding (`intro_seen`).
* Estado de sesión activa.
* Caché del usuario logueado actualmente.
* Historial de búsquedas locales.

## 11. Data local que se debe REEMPLAZAR (Categoría B)
* Catálogo general de destinos (`MockDestinationDataSource.activeDestinations`).
* Envío de reseñas (Redirigir a `POST /api/v1/reviews`).
* Listado de perfiles (Redirigir 100% a backend).
* Galería de imágenes quemada (Migrar a la data rica de `tourism_info.gallery_images`).

## 12. Mocks que pueden quedar como FALLBACK (Categoría C)
* `mock_recommendation_data_source.dart`
* `mock_destination_data_source.dart` (solo como respaldo por si el endpoint de destinos falla, no como método primario).

## 13. Mocks que deben ELIMINARSE (Categoría D)
* `mock_aspect_data_source.dart`: Miente sobre la precisión del modelo ABSA.

## 14. Funcionalidades FUTURAS (Categoría E)
* Cloudinary para avatares (Mantener imagen estática local).
* Creación de Rutas (Deshabilitar en UI o dejar con disclaimer "Próximamente").
* Favoritos reales en backend (Aún no expuesto públicamente).

## 15. Matriz Vista → Endpoint Backend

| Pantalla | Endpoint backend recomendado |
| :--- | :--- |
| `HomeScreen` (Explorar) | **`GET /api/v1/destinations`** |
| `FeedbackScreen` | **`POST /api/v1/reviews`** |
| `DestinationDetailScreen` | `GET /api/v1/destinations/{id}` (Ya implementado) |
| `DestinationDetailScreen` (Sección Info MINCETUR)| **`GET /api/v1/tourism/catalog/{id}`** (Falta conectar) |
| `DestinationDetailScreen` (Reseñas) | **`GET /api/v1/reviews/destination/{id}`** (Falta conectar) |
| `ForYouScreen` | `GET /api/v1/recommendations/contextual` (Ya implementado) |

## 16. Matriz Servicio → Endpoint Backend

| Servicio actual | Endpoint backend recomendado |
| :--- | :--- |
| `DestinationService.getDestinations()` | **`GET /api/v1/destinations`** |
| `FeedbackService.submitFeedback()` | **`POST /api/v1/reviews`** |
| `DestinationService.getAspectScores()` | `GET /api/v1/destinations/{id}` (Extraer de JSON, ya parcialmente hecho) |

## 17. Riesgos de borrar mocks de golpe
Borrar la carpeta `lib/integration/mock/` ahora mismo ocasionaría "pantallas blancas" o errores fatales en `HomeScreen` porque el `DestinationService` no está programado para llamar a `GET /api/v1/destinations`. Todo el catálogo inicial colapsaría.

## 18. Recomendación y Plan para la Fase 2
La transición debe ser gradual.
1. **Paso 1 (Feedback):** Modificar `FeedbackService.dart` para ejecutar `_apiClient.post('/reviews', ...)` y dejar de guardar en `LocalStorageService`. Es el más crítico para lograr la interactividad prometida.
2. **Paso 2 (Explorar):** Modificar `DestinationService.getDestinations()` para consumir `_apiClient.get('/destinations')`. Esto permitirá que la app lea dinámicamente desde PostgreSQL.
3. **Paso 3 (Limpieza):** Una vez validados el Paso 1 y 2, se puede eliminar `mock_aspect_data_source.dart` y reducir las imágenes pesadas de la carpeta `assets/images` quemadas en `mock_destination_data_source.dart`.

---
*Fin de la Auditoría - Fase 1 - Ningún archivo fue modificado ni eliminado.*
