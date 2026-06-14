# Reporte de Cierre: Fase 2D — Mis reseñas / historial del usuario

## Resumen Ejecutivo
Se implementó exitosamente la nueva pantalla de "Mis reseñas" en el perfil de usuario. Esta sección permite a los viajeros consultar de manera transparente el historial de sus opiniones conectadas al backend en tiempo real, respetando las reglas arquitectónicas y el estado actual del proyecto (Fases 2A-2C cerradas).

## Archivos Modificados / Creados
1. **`lib/integration/services/review_service.dart`** [MODIFICADO]
   - Se añadió el método `getReviewsByUser(String userId)` para consumir el endpoint `GET /api/v1/reviews/user/{user_id}`.
2. **`lib/controllers/my_reviews_controller.dart`** [CREADO]
   - Implementa `ChangeNotifier` para gestionar los 4 estados principales de la pantalla (Cargando, Vacío, Error, Éxito).
   - Resuelve dinámicamente el `userId`, asignando temporalmente `U00001` si el usuario no tiene ID válido en el backend (MVP).
3. **`lib/app.dart`** [MODIFICADO]
   - Inyección del nuevo proveedor de estado `MyReviewsController` al árbol global.
4. **`lib/models/review_model.dart`** [MODIFICADO]
   - Se añadieron `destinationId`, `processingMonth` y se tipó fuertemente `aspectRatings` como un mapa (`Map<String, dynamic>`) para soportar correctamente el contrato JSON de respuesta de listado de usuario.
5. **`lib/views/profile/my_reviews_screen.dart`** [CREADO]
   - Pantalla que consume el controlador y renderiza los estados de la petición.
6. **`lib/views/profile/widgets/my_review_card.dart`** [CREADO]
   - Componente de interfaz para representar cada reseña individual, con colorización semántica, mapeo de textos y lógica condicional.
7. **`lib/core/router/app_router.dart`** [MODIFICADO]
   - Registro de la nueva ruta `/profile/my-reviews`.
8. **`lib/views/profile/profile_screen.dart`** [MODIFICADO]
   - Añadido el ítem visual "Mis reseñas" dentro del bloque de acciones de cuenta.

## Endpoints Conectados
- `GET /api/v1/reviews/user/{user_id}`

## Resolución de Reglas de Negocio Implementadas

### Mapeo Amigable de Estado (Status)
Los valores crudos que envía el backend para la llave `status` se ocultaron del usuario. En su lugar se presentan cadenas amigables con colores acordes:
- `pending_processing` -> "Pendiente de análisis" (Amarillo)
- `processed` -> "Procesada" (Verde)
- `used_for_training` -> "Usada para mejora del modelo" (Verde)
- Por defecto -> "Estado no disponible" (Gris)

### Variables Condicionales (`processing_month` y `aspect_ratings`)
- `processing_month` se omitió de la UI si llega como `null` o vacío. Si existe, se muestra discretamente al lado del estado de la reseña, cumpliendo su propósito como dato secundario.
- `aspect_ratings` solo se dibuja (como *chips* o pastillas visuales) si existen campos dentro del objeto devuelto por el backend.

### Manejo de Estados de UI
Se distinguieron exhaustivamente y se construyó UI diferenciada para:
1. **Loading:** Pantalla de "Cargando tus reseñas...".
2. **Vacío Real (`[]`):** Mensaje "Aún no has enviado reseñas. Cuando comentes un destino, aparecerá aquí.".
3. **Error (Timeout / 500 / Offline):** Bloque "No se pudieron cargar tus reseñas. Inténtalo nuevamente." con un botón de **Reintentar** incorporado, logrando resiliencia sin mezclarse con la UI de listado vacío.

## Confirmaciones Obligatorias
- **Fallback `U00001`:** Se confirma que se inyecta `U00001` solo si el usuario activo no proviene de un registro real de backend (fallback temporal MVP). Queda documentado como **Deuda Técnica** a remover cuando se habilite JWT/AuthReal en futuras fases.
- **Sin LocalStorage:** Se confirma que no se persistió ni se leyó el historial en base de datos local; el servicio consulta al servidor vivo cada vez que se entra a la pantalla.
- **Sin Mocks:** Se confirma que en caso de error, el catch del método detona una pantalla de error. No se inyecta ninguna lista pre-armada del `MockDestinationDataSource`.
- **Análisis Limpio:** Se ejecutó `flutter analyze` reportando exactamente `No issues found!`.
- **Límites de Proyecto:** No se tocaron endpoints ni modelos de PostgreSQL en el backend, no se avanzó a la Fase 2D-extendida (edición o borrado de reseñas). Se cumplió estrictamente la especificación de "Solo Lectura".

## Validación visual manual desde Android Studio

**Fecha de validación:** 13 de junio de 2026

Se confirma el cumplimiento de los siguientes puntos tras revisión en emulador:
1. La opción “Mis reseñas” en el perfil abre correctamente la pantalla destino.
2. Se muestran reseñas reales extraídas de PostgreSQL para el usuario `U00001`.
3. Las estrellas utilizan el campo `rating_general`.
4. El texto principal de la reseña viene de `review_text`.
5. Los aspectos (chips) se renderizan correctamente a partir de la lista `aspect_ratings`.
6. La llave `status` se muestra como texto amigable ("Pendiente de análisis", etc.), no como valor crudo.
7. La variable `processing_month` aparece discretamente como dato secundario.
8. No se tocó código, esquemas ni rutas en el backend.
9. No se usaron datos mock (se eliminó dependencia visual del fallback local para reseñas).
10. No se usó `LocalStorage` como fuente de reseñas (la lista siempre proviene del fetch HTTP).

**Conclusión:** La Fase 2D queda cerrada oficialmente.

## Deuda técnica futura

* Reemplazar el fallback `U00001` en `MyReviewsController` cuando exista autenticación real/JWT en el proyecto.
* Reemplazar “Destino ID: machu-picchu” por el nombre amigable del destino obtenido del catálogo, por ejemplo “Machu Picchu”.
* Mapear nombres técnicos de aspectos como `aforo_multitudes` o `atencion_servicio` a etiquetas visuales más amigables (ej. "Aforo/Multitudes", "Atención al Cliente").
* Implementar edición/eliminación de reseñas en una fase posterior, cuando el backend exponga los endpoints `PUT` y `DELETE` para reviews.

---
*Este reporte certifica la finalización técnica de la Fase 2D según los requerimientos solicitados y validados.*
