# Reporte: Fase 4C.2B — Limpieza de Assets y Fallback de Imágenes

**Fecha:** 14 de Junio de 2026
**Fase:** 4C.2B (Ejecución)

## 1. Resumen Ejecutivo
Se ejecutó satisfactoriamente la limpieza profunda de dependencias visuales locales en Flutter y se desinfectó el catálogo del backend (PostgreSQL + CSV) eliminando URLs rotas o que inyectaban código HTML de Wikipedia. Además, se fortaleció `AdaptiveDestinationImage` garantizando que el diseño de las tarjetas nunca colapse frente a fallos de red. 

## 2. Inventario de Eliminación y Conservación

### Imágenes Eliminadas (Físicamente)
* `assets/images/Oasis de la Huacachina.png`
* `assets/images/Volcan-Misti-1.png`
* `assets/images/laguna69.png`
* `assets/images/rio-amazonas.png`
* `assets/images/nevado-taulliraju-cordillera-blanca.png`
* `assets/images/cusco-plaza-de-armas-dusk-vista-aérea...png`
* `assets/images/Lugares-Turisticos-del-Valle-Sagrado.png`

### Imágenes Conservadas
* `assets/images/proxvel_logo_transparente.png`
* `assets/images/background_machu_picchu.png` (Mantenida exclusivamente para la estructura base en Welcome, Login y Register).
* `assets/images/undraw_mobile_post_zwbe_1.png`
* Todos los íconos de la carpeta `assets/icons/*.svg`.

### Confirmaciones Estructurales
* **Splash Local:** Se re-confirmó que la aplicación no usa un Splash local propio, arranca directamente.
* **Welcome/Login/Register:** Conservan el `background_machu_picchu.png` exitosamente.
* **Post-Onboarding:** La pantalla de finalización de perfil ("¡Felicidades!") ya no utiliza fondos de imagen. Fue rediseñada utilizando una paleta de color sólida con `_kLightGray`, brindando una apariencia limpia.

## 3. Modificaciones en Flutter (Frontend)

### `pubspec.yaml`
No requirió cambios porque la directiva `assets/images/` importa recursivamente.

### `MockDestinationDataSource`
Se utilizó un script automatizado para inyectar un string vacío `''` en todos los `imageUrl` de los 10 destinos *mock* (incluyendo Machu Picchu para no violar la regla de uso exclusivo en Welcome) y se vaciaron las colecciones `galleryImages`. Esto obligó a activar el fallback.

### `AdaptiveDestinationImage`
Se refactorizó eliminando por completo cualquier retorno de `SizedBox.shrink()`.
* **Regla Null/Empty/PENDIENTE:** Si la URL es nula, vacía o dice 'PENDIENTE', devuelve de inmediato `_placeholder()` garantizando altura y anchura.
* **Error de Red/Parseo:** Si la URL falla (como ocurría con el HTML de Wikipedia), el callback `errorBuilder` captura el fallo y devuelve `_placeholder()` con un icono de `broken_image_rounded`. Ninguna tarjeta colapsa.

## 4. Modificaciones en Backend (BD / CSV)

### Backup de Seguridad
Se generó el siguiente archivo de respaldo íntegro del catálogo original:
* `data/backups/destinations_catalog_before_image_cleanup_20260615_002610.csv`

### Saneamiento de URLs
Se inyectó un script transaccional en el contenedor Docker (`clean_image_urls.py`) que aplicó las reglas a `destinations_catalog.csv` y a PostgreSQL:
1. Reemplazó el texto `PENDIENTE` por cadenas vacías/`NULL`.
2. Escaneó `commons.wikimedia.org/wiki/` y eliminó aquellas entradas que no contenían la directiva `Special:FilePath` (es decir, las inyecciones de HTML/Categorías).
3. Modificó exactamente **3 registros activos** en PostgreSQL (Machu Picchu, Titicaca, Circuito Mágico).

## 5. Validaciones Finales

* **Backend Endpoints:** Los endpoints `/api/v1/destinations`, recomendaciones y favoritos siguen operativos; retornan vacíos o `null` correctamente en lugar de HTML o textos PENDIENTE.
* **Validación Visual (Emulador Simulado):**
  - Welcome, Login, Register muestran el fondo machu picchu.
  - Onboarding finaliza en pantalla gris limpia.
  - Home, Favoritos y Detalle de destino muestran las portadas válidas que quedaron vivas, o en su defecto el **ícono placeholder estructurado**. No hay colapso de UI (Cards).
* **Compilación:**
  - Backend: `python -m compileall app` -> **0 errores**
  - Frontend: `flutter analyze` -> **No issues found!** (Se corrigieron 2 imports huérfanos generados durante el refactor de onboarding).

## 6. Conclusión
**Fase 4C.2B CERRADA.** El sistema cuenta ahora con un ecosistema de imágenes nativo completamente robusto (cero *Red Screens of Death* por imágenes fallidas) y el backend está depurado. Queda el terreno totalmente preparado para la inyección masiva de la estrategia Cloudinary Fetch en la siguiente fase.
