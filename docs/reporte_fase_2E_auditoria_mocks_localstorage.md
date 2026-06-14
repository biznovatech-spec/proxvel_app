# Reporte de Fase 2E — Auditoría y limpieza controlada de mocks y LocalStorage

## 1. Resumen Ejecutivo
Se realizó una revisión técnica de la arquitectura del frontend (`proxvel_app`) tras las implementaciones de las Fases 2A a 2D. El objetivo es identificar código muerto (mocks obsoletos) y funciones locales (`LocalStorageService`) que ya fueron delegadas al backend, para así planificar una limpieza segura (Fase 2E.1) sin comprometer el funcionamiento MVP actual.

## 2. Archivos Mock Encontrados
- `lib/integration/mock/mock_destination_data_source.dart`
- `lib/integration/mock/mock_recommendation_data_source.dart`
- `lib/integration/mock/mock_aspect_data_source.dart`
- `lib/integration/mock/mock_route_data_source.dart`

## 3. Pantallas, Controladores y Servicios que todavía usan Mocks
- `DestinationService`: Usa `MockDestinationDataSource` como fallback (excepto en la galería, que se corrigió en Fase 2C) y `MockAspectDataSource` para scores y explicaciones.
- `RecommendationService`: Usa `MockRecommendationDataSource` como fallback si falla `/recommendations/contextual`.
- `RouteService`: Depende totalmente de `MockRouteDataSource` (no hay backend implementado).
- `SearchController`: Usa `MockAspectDataSource.getCompatibility` de forma directa para el badge.

## 4. Usos actuales de `LocalStorageService`
El servicio local está muy activo, soportando las siguientes funciones:
- **Core de UI:** `introSeen`, `isSessionActive`.
- **Sesión (Mocks):** `saveUser`, `getUser`, `registerUser`, `getAllRegisteredUsers`, `findUserByEmail`.
- **Perfil Viajero (Mock):** `saveProfile`, `getProfile`.
- **Favoritos (Mock):** `addFavorite`, `removeFavorite`, `getFavorites`.
- **Rutas Completadas (Mock):** `markRouteCompleted`, `markRouteActive`, `getCompletedRoutes`.
- **Búsquedas Recientes:** `addRecentSearch`, `getRecentSearches`, `clearRecentSearches`.
- **Feedback (Código Muerto):** `saveFeedback`, `getFeedbackList` (ya no se llaman desde ningún servicio).

## 5. Tabla de Clasificación

| Elemento | Archivo | Uso actual | Estado recomendado | Riesgo si se elimina | Acción sugerida |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Feedback local** | `local_storage_service.dart` | Ninguno (Orphan) | **A. Eliminar ahora** | Nulo | Borrar funciones de feedback. |
| **MockDestination** | `mock_destination_data_source.dart` | Fallback en Explorar | **B. Fallback MVP** | Medio (App rompe si cae backend) | Conservar de momento. |
| **MockRecommendation** | `mock_recommendation_data_source.dart` | Fallback de /recommendations | **B. Fallback MVP** | Medio (App rompe si cae backend) | Conservar de momento. |
| **MockAspect** | `mock_aspect_data_source.dart` | `SearchController`, Fallbacks | **D. Reemplazar luego** | Alto (Rompe UI del detalle) | Conservar hasta asegurar backend para aspectos detallados. |
| **MockRoute** | `mock_route_data_source.dart` | `RouteService` | **C. Depende backend futuro** | Alto (Rompe tab Rutas) | Conservar. |
| **Auth Local** | `local_storage_service.dart` | `AuthController` | **C. Depende backend futuro** | Crítico (Impide login visual) | Conservar. |
| **Favoritos Local** | `local_storage_service.dart` | `FavoritesController` | **C. Depende backend futuro** | Crítico (Rompe tab Favoritos) | Conservar. |
| **Búsquedas Recientes** | `local_storage_service.dart` | Caché en `SearchController` | **Conservar (Válido)** | Nulo | Uso correcto de persistencia UI. |

## 6. Mocks que pueden eliminarse ahora (Fase 2E.1)
- Funciones `saveFeedback` y `getFeedbackList` de `LocalStorageService` (y la importación de `FeedbackModel` en ese archivo). Ya usamos `POST /reviews`.

## 7. Mocks que deben mantenerse como fallback MVP
- `MockDestinationDataSource` y `MockRecommendationDataSource`. Actúan como malla de seguridad si PostgreSQL o FastAPI fallan.

## 8. Datos quemados que siguen en la UI
- `U00001`: Fallback en `MyReviewsController` y `FeedbackController`.
- Texto quemado de "Destino ID:" en `MyReviewCard` (falta diccionario de nombres).
- Imágenes locales fallback en la portada de Explorar (se quitaron del detalle, pero siguen en Home).

## 9. Dependencias que requieren backend futuro
- **Autenticación (JWT):** Requiere módulo completo en backend para borrar el Auth Mock.
- **Rutas Turísticas:** Requiere tabla y endpoints en PostgreSQL para borrar `MockRouteDataSource`.
- **Perfil Editable:** Requiere endpoints de `TravelerProfile` para borrar `saveProfile`.
- **Favoritos:** Requiere tabla de relación `user_favorites` para borrar su dependencia de LocalStorage.

## 10. Recomendación priorizada para la Fase 2E.1 de Limpieza
1. Borrar `saveFeedback` y `getFeedbackList` de `LocalStorageService`.
2. Remover importaciones no utilizadas (`FeedbackModel` del storage).
3. Asegurarse de que el `SearchController` no dependa del mock de aspectos de manera tan acoplada si puede leer del backend.

## 11. Recomendación de qué NO tocar todavía
- No tocar el flujo de registro local / login. Si se elimina, no se podrá entrar a la app.
- No borrar `MockRouteDataSource` ni Favoritos.
- No tocar los fallback en `DestinationService` y `RecommendationService`.

---

**Confirmaciones de Cierre de Auditoría:**
- [x] No se modificó backend.
- [x] No se borró ningún archivo de código.
- [x] `flutter analyze` sigue marcando 0 issues.
