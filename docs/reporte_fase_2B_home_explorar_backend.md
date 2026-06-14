# Fase 2B: Conexión de HomeScreen (Catálogo General) con Backend Real

Este reporte documenta la implementación y validación de la Fase 2B, que conecta la pestaña "Explorar" de la aplicación con PostgreSQL a través de FastAPI, desplazando el uso de `MockDestinationDataSource` estrictamente a un rol de *fallback*.

## 1. Archivos Modificados
*   `lib/models/destination_model.dart`: Se agregó el factory `DestinationModel.fromApiCatalog(Map<String, dynamic> json)` para deserializar la respuesta exacta de `GET /api/v1/destinations`.
*   `lib/integration/services/destination_service.dart`: Se modificó el método `getDestinations()` para inyectar la llamada a la API y capturar excepciones manejando el fallback a mock si hay falla de conexión.
*   `task.md`: Actualizado con el checklist de esta fase.

## 2. Endpoint Conectado
*   **Método:** `GET`
*   **Ruta:** `/api/v1/destinations`
*   **Función:** Provee el catálogo general activo del sistema.

## 3. Mapeo de Campos del Backend
La estructura de la base de datos se mapeó al `DestinationModel` del frontend de la siguiente manera:
*   `destination_id` ➔ `id`
*   `destination` ➔ `name`
*   `city` ➔ `city`
*   `region` ➔ `region`
*   `category` ➔ `category` y `type`
*   `cover_image_url` ➔ `imageUrl` (Con fallback a la imagen de los assets locales si la URL del backend viene vacía).

## 4. Campos de la UI sin respaldo del Backend
La API `/destinations` entrega un catálogo muy ligero diseñado para listados. Por ende, los siguientes atributos del modelo de Flutter se inicializan en `null` o `false` para no inventar datos:
*   `distanceKm` (null)
*   `estimatedDays` (null)
*   `isTrending` (false)
*   `averageCost` (0.0)

**Impacto Visual:** Gracias a la programación defensiva previa en `HomeExploreContent`, al no haber destinos con `isTrending == true`, la sección "Lugares turísticos del momento" se oculta automáticamente. Lo mismo ocurre con "Cerca de ti" y "Escapadas". La UI se mantiene intacta, limpia y no engaña al usuario.

## 5. Mock como Fallback Temporal
*   **Confirmación:** La clase `MockDestinationDataSource` **no fue borrada**, pero ya **no es la fuente principal**.
*   **Lógica:** Si `await _api.get('/destinations')` devuelve código 200, la app muestra los datos reales. Si el backend está caído, la consola imprimirá `[DestinationService] Backend no disponible, usando MockDestinationDataSource como fallback` y la app pintará los mocks, evitando el colapso (pantalla blanca) de la vista principal.

## 6. Resultado de `flutter analyze`
El análisis estático de Flutter fue ejecutado, y pasó sin ninguna alerta.
> `No issues found! (ran in 15.6s) - Exit code: 0`

## 7. Evidencia de Comportamiento
*   **Con backend activo:** La app consulta FastAPI y extrae, por ejemplo, "Machu Picchu", "Lago Titicaca", etc. Las tarjetas se renderizan utilizando los nombres reales.
*   **Con backend apagado:** La app intenta conectar. Tras el timeout o `ConnectionRefusedError`, captura la excepción silenciosamente e inyecta la lista de los 11 destinos del mock. Esto previene un fatal crash en producción.

## 8. Conclusión
La **Fase 2B ha concluido**. El `HomeScreen` de PROXVEL ahora depende del inventario real en base de datos. Se han respetado estrictamente las reglas de no modificar el diseño visual y no inventar datos inexistentes.
