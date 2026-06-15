# Reporte de Fase 4C.1 — Auditoría y estrategia de multimedia y portadas

## 1. Resumen Ejecutivo
Esta fase de diagnóstico se enfocó en auditar el ecosistema de manejo de imágenes (portadas principales y galerías) entre FastAPI y Flutter en el proyecto PROXVEL. Actualmente, el flujo existe y la arquitectura base está preparada: el backend devuelve los campos correctos y el frontend posee un componente centralizado. Sin embargo, el contenido real de los datos (fuentes de imágenes) proviene de Wikimedia Commons, lo cual acarrea enlaces rotos, URLs que apuntan a páginas web en lugar de imágenes estáticas y cadenas marcadas como `PENDIENTE`.

Se recomienda la **Opción B (Cloudinary)** como el paso a seguir para la Fase 4C.2, sin necesidad de modificar el esquema de base de datos actual.

---

## 2. Estado actual de imágenes en backend

1. **¿Dónde se guarda actualmente la imagen principal del destino?**
   Se guarda en la columna `cover_image_url` de la tabla `tourism_catalog`, poblada a partir del CSV `data/destinations_catalog.csv`.
2. **¿El backend devuelve `cover_image_url` en catálogo?**
   Sí, en los esquemas `DestinationSummary` y `DestinationDetail`.
3. **¿El backend devuelve `cover_image_url` en recomendaciones?**
   Sí, en los esquemas `RecommendationItem` y `RecommendationMeItem`.
4. **¿El backend devuelve `cover_image_url` en favoritos?**
   Sí, en el esquema `FavoriteItemResponse`.
5. **¿Existe galería por destino?**
   Sí, la tabla `tourism_catalog` posee 4 columnas de soporte: `gallery_image_1` hasta `gallery_image_4`.
6. **¿Las imágenes vienen de Cloudinary, URLs externas o assets locales?**
   La base de datos contiene URLs externas directas (mayoritariamente de *Wikimedia Commons*, ej: `https://commons.wikimedia.org/wiki/Special:FilePath/...`).
7. **¿Hay destinos sin imagen?**
   Sí, muchos registros tienen asignado el valor `"PENDIENTE"` en el CSV para los campos de la galería.
8. **¿Hay URLs rotas o vacías?**
   Existen múltiples URLs rotas. Varias URLs de Wikimedia no apuntan directamente a una imagen `.jpg` o `.png`, sino a la página web del recurso (ej: `https://commons.wikimedia.org/wiki/Category:Machu_Picchu`).
9. **¿Qué endpoint debería encargarse de entregar imágenes?**
   Ningún endpoint del backend debería servir el archivo binario. El backend simplemente expone las URLs pre-firmadas o estáticas como strings dentro de las peticiones JSON existentes (`/destinations`, `/recommendations`, `/favorites`).
10. **¿Hace falta una tabla nueva o basta con campos existentes?**
    Basta con los campos actuales. El modelo `TourismCatalog` ya cuenta con `cover_image_url`, `gallery_image_[1-4]`, `image_source` y `image_license_note`.

---

## 3. Estado actual de imágenes en Flutter

1. **¿Qué cards usan imágenes?**
   `DestinationCard`, `TrendingDestinationCard`, `DestinationRecommendationCard`, `SearchResultCard` y `DestinationGalleryPreview`.
2. **¿Qué pasa si `cover_image_url` viene null?**
   El modelo `DestinationModel` limpia las URLs inválidas (ej. descarta `"PENDIENTE"`). El componente de interfaz se apoya en un string vacío.
3. **¿Hay placeholder visual?**
   Sí, `AdaptiveDestinationImage` contiene el método `_placeholder()`, que renderiza un cuadro gris neutro con el ícono `Icons.landscape_outlined`.
4. **¿Hay errorBuilder en `Image.network`?**
   Sí, pero su implementación es agresiva: devuelve `const SizedBox.shrink()`, lo que provoca que si la imagen de red de Wikimedia da un 404/403, el componente se colapse y rompa la estructura visual de las tarjetas.
5. **¿Hay imágenes locales en assets?**
   Sí, `AdaptiveDestinationImage` hace fallback a `Image.asset` si la URL no empieza por `http`. Esto sirvió durante la fase de prototipado.
6. **¿La pantalla de detalle tiene galería?**
   Sí, controlada por el widget `DestinationGalleryPreview` el cual gestiona la visualización condicional (1 imagen, 2-3 imágenes, ver todo).
7. **¿Favoritos muestra imagen correctamente?**
   Sí, consume `DestinationCard` (usando `AdaptiveDestinationImage`). Depende de la estabilidad de la URL.
8. **¿Recomendaciones muestra imagen correctamente?**
   Sí, mediante `DestinationRecommendationCard` y `AdaptiveDestinationImage`.
9. **¿Hay duplicación de lógica de imagen?**
   Afortunadamente no. El 100% de la carga visual remota y local pasa a través del widget central `AdaptiveDestinationImage`.
10. **¿Qué componente debería centralizar la carga de imágenes?**
    El ya existente `AdaptiveDestinationImage`, con sugerencias de mejora de cacheo y manejo de errores.

---

## 4. Evaluación de Estrategias a Comparar

### Opción A — URLs externas directas (Situación Actual)
* **Estado**: Es lo que usa actualmente el CSV (Wikimedia).
* **Evaluación**: Muy propenso a roturas (link rot). Wikimedia suele bloquear peticiones hotlinking o devolver un 403 Forbidden. Falla fuertemente en proporcionar una experiencia "Premium" estipulada en los objetivos del negocio.

### Opción B — Cloudinary
* **Estado**: No implementado.
* **Evaluación**: **Excelente.** Permite centralizar los recursos estáticos, optimizar el peso al vuelo (con recortes cuadrados o rectangulares ideales para la UI de Flutter sin deformar la imagen), compresión webp nativa, y evita problemas de CORS/hotlinking. 

### Opción C — Assets locales Flutter
* **Estado**: Usado parcialmente para mocks.
* **Evaluación**: Inviable a escala. Agregar 100+ imágenes de destinos en alta definición dispararía el tamaño del APK/AAB a niveles inaceptables.

---

## 5. Recomendación Técnica Final

Se recomienda unánimemente proceder con la **Opción B (Cloudinary)**.

Adicionalmente, se recomienda actualizar en Flutter el componente `AdaptiveDestinationImage` utilizando el paquete `cached_network_image` para cachear las imágenes de Cloudinary en disco, reduciendo costos de transferencia y mejorando radicalmente la UX en navegaciones repetidas y modo offline temporal. Además, se debe corregir el `errorBuilder` actual (`SizedBox.shrink()`) para que, ante cualquier fallo o link roto, muestre consistentemente el `_placeholder()`.

---

## 6. Propuesta de Contrato Visual

Se establecerá que:
* Todos los endpoints de FastAPI retornarán URLs válidas (absolutas de Cloudinary) en las propiedades `cover_image_url` y la lista de galería.
* Si el recurso no posee imagen en la BD de Cloudinary, el backend pasará `null` o una cadena vacía.
* Flutter identificará esto y lanzará el **Fallback Visual Honesto** (Fondo estético + `Imagen no disponible` o `Ícono`) para no interrumpir el "WOW Effect" de la App.

---

## 7. Plan Propuesto para Fase 4C.2

1. **Backend**:
   - Crear un script Python que actualice en masa el archivo `data/destinations_catalog.csv` y/o la BD para reemplazar URLs rotas de Wikimedia por URLs limpias de Cloudinary (o strings vacíos/null seguros).
2. **Flutter**:
   - Migrar `AdaptiveDestinationImage` de `Image.network` a `CachedNetworkImage` para rendimiento y caché.
   - Refactorizar el `errorBuilder` en `AdaptiveDestinationImage` para forzar la muestra del placeholder visual si la imagen falla.
   - Reemplazar `SizedBox.shrink()` en el fallback para evitar que las Cards colapsen.

---

## 8. Confirmación de Restricciones
- **Se modificó código:** NO.
- **Se modificó la base de datos:** NO.
- **Se alteraron endpoints:** NO.

## Conclusión
La arquitectura soporta las imágenes reales de inmediato sin necesidad de cambios estructurales ni nuevas tablas de base de datos. El principal cuello de botella es la **calidad de los datos** (URLs de Wikimedia rotas). El ecosistema está listo para la migración visual planificada en la **Fase 4C.2**.
