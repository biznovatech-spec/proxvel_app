# Fase 2C: Enriquecimiento de Detalles del Destino con MINCETUR y Reseñas Reales

Este reporte documenta la implementación de la Fase 2C, logrando que la pantalla de detalles de destino consuma catálogos oficiales e incorpore un sistema de opiniones en vivo.

## 1. Endpoints Conectados
Se consumen los siguientes endpoints de la API de FastAPI:
- `GET /api/v1/tourism/catalog/{destination_id}`: Para información oficial.
- `GET /api/v1/reviews/destination/{destination_id}`: Para reseñas de usuarios.

## 2. Modelos Creados
- `lib/models/tourism_catalog_model.dart`: Encapsula todos los campos provistos por MINCETUR (official_name, department, province, district, altitude_m, description, experience_type, accessibility_summary, etc.).
- `lib/models/review_model.dart`: Encapsula los comentarios (rating_general, review_text, user_id, status, aspect_ratings).

## 3. Servicios y Arquitectura
- Se crearon `TourismService` y `ReviewService` encapsulando la lógica HTTP de dichos dominios.
- Se actualizaron las inyecciones de dependencias en `app.dart` mediante `ProxyProvider`.
- El controlador `DestinationController` fue refactorizado para cargar los datos en paralelo.

## 4. Campos del Catálogo MINCETUR Mostrados
La pestaña "Sobre el destino" fue modificada (`AboutDestinationTabContent`). Cuando la API devuelve datos oficiales, se inyecta un bloque visual distinguido que presenta:
- Nombre oficial
- Ubicación estructurada (Distrito, Provincia, Departamento)
- Tipo y Subtipo
- Jerarquía
- Experiencia
- Altitud
- Resumen de Actividades y Accesibilidad.

## 5. Reseñas Mostradas
Se creó una tercera pestaña ("Opiniones") utilizando el widget `ReviewsTabContent`:
- Muestra el texto de la reseña, el ID del usuario y las estrellas asignadas dinámicamente según `rating_general`.
- **Estado Vacío:** Si la API devuelve `[]`, se muestra un mensaje "Aún no hay opiniones... Sé el primero".
- **Llamado a la acción:** Incluye un botón para enviar feedback que redirige correctamente a `/feedback/:id`.

## 6. Cálculo de Promedio de Estrellas
El promedio se calcula directamente en el Frontend (dentro de `DestinationController.loadDestination()`) sumando los `rating_general` de la respuesta de reseñas y dividiéndolo por el conteo total. Este valor sobrescribe el puntaje de la interfaz ("X.X rating"). Si no hay reseñas, se ocultan las estrellas o se marca como "Nuevo".

## 7. Manejo de Errores y Carga
El controlador maneja `try/catch` para ambos endpoints de forma independiente. Si el backend rechaza uno de los endpoints, las variables regresan a null o listas vacías, previniendo crashes y mostrando fallbacks estéticos.

## 8. Resultado de `flutter analyze`
```text
No issues found! (ran in 14.6s)
Exit code: 0
```
*(Nota: Se solventó un lint sobre el uso de doble guion bajo).*

## 9. Reglas Críticas Confirmadas
- **No se tocó backend:** El backend de FastAPI permanece intacto.
- **No se usaron reseñas mock:** Si no hay reseñas en base de datos para ese slug, no se muestran reseñas simuladas.
- **No hay JWT ni Cloudinary:** Se mantiene la autenticación e imágenes dummy según lo planeado.

## Conclusión
La **Fase 2C** fue completada satisfactoriamente. La vista de detalles del destino es ahora dinámica, honesta y extrae su robustez directamente de la información oficial indexada y las experiencias sociales almacenadas en PostgreSQL.

## 10. Checklist de validación manual pendiente

Dado que no dispongo de un entorno visual/runtime (emulador Android/iOS) integrado para visualizar pantallas en Flutter, por favor realiza la siguiente validación manual desde Android Studio para cerrar oficialmente la fase:

### Instrucciones de validación en UI:
1. **Ruta:** Levanta el backend de FastAPI y la app Flutter. Navega a la pestaña "Explorar" y haz tap en la tarjeta de **Machu Picchu**.
2. **Pestañas:** En la pantalla de detalle, ubica las pestañas centrales. Deberías ver tres: "¿Por qué para mí?", "Sobre el destino", y "Opiniones".
3. **Catálogo MINCETUR:** Abre la pestaña **"Sobre el destino"**.
   - Debería aparecer un bloque con un ícono verde llamado "Información Oficial (MINCETUR)".
   - Textos esperados: Nombre oficial, Ubicación (Machupicchu, Urubamba, Cusco), Tipo, Jerarquía (Jerarquía 4), Altitud (2430.0 m.s.n.m.).
4. **Reseña Real:** Abre la pestaña **"Opiniones"**.
   - Si no hay reseñas, debería verse el texto: *"Aún no hay opiniones para este destino. Sé el primero en comentar."*
   - Si dejaste la reseña en la Fase 2A, debería aparecer el texto: *"Esta es una reseña de prueba desde la validación de la app."* y Usuario: `U00001`.
5. **Estrellas:** En esa misma pestaña de "Opiniones", deberías ver `4.5` visualizado como 4 estrellas y media, que corresponden al `rating_general` de tu reseña. El promedio en la cabecera (en la foto principal) debe decir `4.5 según opiniones`. Este texto aclara que es estrictamente un promedio social y no el algoritmo de recomendación ABSA.
6. **Logs:** En la consola de Android Studio (o backend), deberían registrarse las peticiones a `GET /api/v1/tourism/catalog/machu-picchu` y `GET /api/v1/reviews/destination/machu-picchu`.
7. **Prueba de Fallo:** Apaga el backend de FastAPI y vuelve a entrar al detalle.
   - La pantalla debe cargar sin crashear.
   - La pestaña "Sobre el destino" mostrará la descripción por defecto (sin el bloque MINCETUR).
   - La pestaña "Opiniones" mostrará un cuadro de error rojo diciendo: *"No se pudieron cargar las opiniones. Inténtalo nuevamente."*

### Confirmaciones Técnicas
Confirmo técnicamente el cumplimiento absoluto de las siguientes reglas de la Fase 2C:
*   ✅ `flutter analyze` se ejecutó en la carpeta `proxvel_app` y arrojó **0 issues**.
*   ✅ El backend **no** fue modificado de ninguna manera.
*   ✅ **No** se usaron reseñas mock.
*   ✅ **No** se activó ni configuró Cloudinary.
*   ✅ **No** se implementó edición o eliminación de reseñas.
*   ✅ El promedio de estrellas calculado se basa **estrictamente** en el atributo `rating_general` extraído del endpoint de opiniones. No existe ninguna contaminación cruzada con los modelos ABSA, porcentajes de compatibilidad o scores de recomendación algorítmica.

El cumplimiento de esta validación manual confirmará definitivamente el cierre de la Fase 2C.

## 11. Correcciones visuales y de mapeo posteriores a validación manual

Tras la validación visual manual inicial, se detectaron y corrigieron los siguientes aspectos para garantizar la fidelidad con los datos del backend:
1. **Jerarquía y Altitud:** Se ajustó el parseo en `TourismCatalogModel` para manejar correctamente números en el campo `hierarchy` y se configuró el `KeyInfoGrid` para consumir prioritariamente los datos de `TourismCatalogModel`, resolviendo el problema donde se mostraban como `N/A`.
2. **Claridad del bloque MINCETUR:** Se agregó explícitamente la fuente *"Inventario de Recursos Turísticos del Perú - MINCETUR"*, además de sus códigos y enlaces correspondientes en la pestaña de detalles, haciéndolo un bloque más distinguido.
3. **Ubicación Geográfica en Mapa:** Se actualizaron `TourismCatalogModel` y `MapLocationPreview` para capturar `latitude` y `longitude`. Ahora, si las coordenadas son nulas, se oculta el mapa simulado y se muestra un mensaje: *"Ubicación geográfica no disponible en la fuente oficial."* previniendo confusiones.
4. **Galería de Imágenes:** Se añadió un filtrado en `TourismCatalogModel.fromJson` para ignorar imágenes que no sean directas (ej. enlaces de páginas wiki), previniendo loaders infinitos o imágenes rotas en el `DestinationGalleryPreview`.

## 12. Corrección final de galería tras validación visual manual

Tras una segunda revisión de la galería en la vista de detalle (`DestinationGalleryPreview`), se refactorizó la lógica de renderizado para solucionar problemas de placeholders rotos, loaders infinitos y slots vacíos:
- **Filtrado estricto:** El widget ahora procesa la lista `imageUrls` antes del renderizado, reteniendo únicamente URLs directas hacia extensiones válidas de imagen (`.jpg`, `.png`, `.webp`, etc.) e ignorando páginas HTML engañosas.
- **Renderizado condicional:** Si no existen imágenes válidas, el bloque completo de la galería se oculta limpiamente (`SizedBox.shrink()`).
- **Adaptación de slots:** Se eliminó la obligación de ocupar 3 espacios fijos. Si solo hay 1 imagen válida, se renderiza una sola tarjeta sin dejar vacíos, y los indicadores inferiores se adaptan o se ocultan consecuentemente.
- **Acciones dinámicas:** El botón de "Ver todas" ahora está condicionado al éxito del filtrado.

## 13. Corrección definitiva de galería tras tercera validación visual

Para erradicar definitivamente la aparición de "slots fantasmas", spinners persistentes y placeholders rotos, se aplicó una reestructuración completa sobre el motor de renderizado de la galería tras descubrir el origen real del bug:

- **Causa exacta del segundo slot fantasma:** El filtro de validación previo permitía erróneamente que URLs de páginas HTML de Wikipedia (ej. `es.wikipedia.org/wiki/Archivo:Machu_Picchu.jpg`) pasaran como "imágenes válidas" porque terminaban en `.jpg`. Al intentar cargarlas, `Image.network` se quedaba colgado en el `loadingBuilder` o fallaba, mostrando permanentemente el `_placeholder()` (el bloque gris con la montaña), contando falsamente como una segunda imagen. El filtro ahora exige estrictamente que la URL no contenga `/wiki/` (las imágenes directas de Wikipedia usan `/wikipedia/commons/`), y rechaza los strings `'null'` o rutas rotas explícitamente.
- **Archivo exacto corregido:** `lib/views/destination/widgets/destination_gallery_preview.dart`.
- **Regla aplicada para 0 imágenes:** Se retorna `SizedBox.shrink()`, ocultando de raíz toda la sección "Galería" y todos sus componentes.
- **Regla aplicada para 1 imagen:** Se renderiza una única tarjeta usando un bloque de diseño exclusivo (`SingleImageGallery` en línea). Sin dots, sin `ListView`, sin "Ver todas".
- **Regla aplicada para 2 o más imágenes:** Se activa el `ListView.separated` condicionado a la cantidad real de `validImages`.
- **Confirmación de `itemCount`:** El `itemCount` ya no usa topes `max(3)` ni anclajes fijos, sino estrictamente `displayImages.length`.
- **Confirmación de placeholders:** Al limpiar la lista de basura como `"null"` y páginas HTML de Wikipedia, las tarjetas grises de relleno ya no se generan.
- **Confirmación de "Ver todas" y Dots:** Ambos elementos están encapsulados lógicamente para no existir jamás si solo hay una imagen disponible.

## 14. Decisión final sobre galería y datos de imagen

Para garantizar la total honestidad de la interfaz respecto a los datos provistos por el backend, se eliminó la lógica de fallback que rellenaba la galería y la portada con imágenes locales de prueba (mocks) cuando el backend devolvía URLs vacías o inválidas.

- **Regla de oro aplicada:** Si la API no provee imágenes válidas, la UI **oculta completamente** la sección Galería (sin título, sin botón "Ver todas", sin dots y sin imágenes de prueba simuladas). Si provee solo 1 imagen válida, se muestra únicamente esa imagen sin indicadores extra.
- **Prohibición de mocks:** Ya no se usa `MockDestinationDataSource` para inyectar `assets/images/...` en destinos reales que carecen de galería en la API.
- **Transparencia:** La pantalla de detalle reflejará exactamente lo que la base de datos de turismo tiene disponible.
- **Fase Futura (Cloudinary):** La carga y entrega de una galería rica y real de imágenes queda delegada formalmente a una futura fase específica de backend (Cloudinary / almacenamiento S3), sin ensuciar la actual fase de validación de datos turísticos textuales.
- **Estado del proyecto:** Todo el trabajo se mantuvo **estrictamente en el frontend**, sin tocar el backend, y **no se avanzó a la Fase 2D**, manteniendo la Fase 2C lista para su cierre final.
