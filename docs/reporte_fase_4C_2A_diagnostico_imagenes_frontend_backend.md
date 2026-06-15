# Fase 4C.2A: Diagnóstico de Imágenes en PROXVEL

**Fecha:** 14 de Junio de 2026
**Objetivo:** Auditar y documentar el uso de imágenes locales (Flutter) y remotas (PostgreSQL/CSV) para planificar la limpieza y migración a portadas reales con Cloudinary, asegurando un fallback visual robusto.

---

## 1. Resumen Ejecutivo
Se realizó una auditoría completa del proyecto. 
En el **Frontend**, se encontraron **10 imágenes locales** dentro de `assets/images/`. No existe un Splash Screen local personalizado, pero la imagen de Machu Picchu (`background_machu_picchu.png`) se reutiliza sabiamente en múltiples pantallas estructurales (Welcome, Login, Register). Gran parte de las imágenes locales son mocks de destinos que deben eliminarse.
En el **Backend**, existen 3 destinos activos en el catálogo (`machu-picchu`, `lago-titicaca`, `circuito-magico-del-agua`). Las imágenes principales (`cover_image_url`) apuntan a Wikimedia y cargan, pero muchas imágenes de las galerías están rotas porque **apuntan a páginas HTML de Wikipedia o categorías**, no a archivos de imagen reales, lo que genera errores de parseo en Flutter.

---

## 2. Inventario de Imágenes Locales (Flutter)

Las imágenes locales se encuentran en `C:\Users\danie\Documents\Proyectos\PROXVEL\proxvel_app\assets\images\`.

| Archivo | Vista donde aparece | Tipo | Acción Sugerida |
| :--- | :--- | :--- | :--- |
| `proxvel_logo_transparente.png` | `ProfileScreen` (About Dialog) | Logo / Branding | **CONSERVAR** |
| `background_machu_picchu.png` | `AuthLayoutWrapper` (Welcome, Login, Register) y Mock Data | Welcome / Estructura | **CONSERVAR** (Cumple función estructural). |
| `undraw_mobile_post_zwbe_1.png` | `OnboardingProfileScreen` | Ilustración Onboarding | **CONSERVAR** (Hasta que exista rediseño). |
| `Lugares-Turisticos-del-Valle-Sagrado.png` | `OnboardingProfileScreen` (Success) y Mock Data | Fondo post-onboarding | **ELIMINAR EN SIGUIENTE PASO** (Regla del usuario). |
| `Oasis de la Huacachina.png` | `MockDestinationDataSource` | Destino Mock | **ELIMINAR EN SIGUIENTE PASO** |
| `Volcan-Misti-1.png` | `MockDestinationDataSource` | Destino Mock | **ELIMINAR EN SIGUIENTE PASO** |
| `laguna69.png` | `MockDestinationDataSource` | Destino Mock | **ELIMINAR EN SIGUIENTE PASO** |
| `rio-amazonas.png` | `MockDestinationDataSource` | Destino Mock | **ELIMINAR EN SIGUIENTE PASO** |
| `nevado-taulliraju-cordillera-blanca.png` | `MockDestinationDataSource` | Destino Mock | **ELIMINAR EN SIGUIENTE PASO** |
| `cusco-plaza-de-armas...png` | `MockDestinationDataSource` | Destino Mock | **ELIMINAR EN SIGUIENTE PASO** |

> **Nota sobre Íconos:** Existen 37 archivos `.svg` en `assets/icons/`. Todos son estructurales (branding, UI, categorías de onboarding) y deben ser **CONSERVADOS**.

### Respuestas a puntos específicos del Frontend:
1. **¿Splash visual propio?** No, la app usa la pantalla `Welcome` nativa de Flutter como punto de entrada.
2. **¿Imagen del Welcome?** Sí, `background_machu_picchu.png`.
3. **¿Imagen compartida Welcome/Login/Register?** Sí, el componente `AuthLayoutWrapper` reutiliza `background_machu_picchu.png` para mantener consistencia.
4. **¿Imagen de fondo post-onboarding?** Sí, `Lugares-Turisticos-del-Valle-Sagrado.png` se usa con un blur en la pantalla de "Felicidades".
5. **¿Fotos locales de destinos?** Sí, hay varias como el Río Amazonas, Misti, etc. Solo se usan en el archivo `mock_destination_data_source.dart`.
6. **¿Placeholder local?** No hay una imagen placeholder como tal; `AdaptiveDestinationImage` renderiza un contenedor gris con un ícono de Flutter (`Icons.landscape_outlined`).

---

## 3. Inventario de URLs Remotas (Backend)

Revisión del archivo `data/destinations_catalog.csv` y la tabla `tourism_catalog` en PostgreSQL.

### Estado por Destino

#### 1. Machu Picchu (`machu-picchu`)
- **cover_image_url:** `...Special:FilePath/Machu_Picchu.png` (Válida, pero propensa a fallos).
- **gallery_image_1:** `...Machu_Picchu,_Peru.jpg` (Válida)
- **gallery_image_2:** `...Juin_2009_-_edit.jpg` (Válida)
- **gallery_image_3:** `https://commons.wikimedia.org/wiki/Machu_Picchu` (**ROTA / HTML**)
- **gallery_image_4:** `https://commons.wikimedia.org/wiki/Category:Machu_Picchu` (**ROTA / HTML**)

#### 2. Lago Titicaca (`lago-titicaca`)
- **cover_image_url:** `...Lago_Titicaca,_Puno,_Perú...JPG` (Válida, pero caracteres especiales como `ú` rompen algunos clientes HTTP).
- **gallery_image_1:** `...Lago_Titicaca,_Copacabana-Bolivia.jpg` (Válida)
- **gallery_image_2:** `...Lago_titicaca_001.png` (Válida)
- **gallery_image_3:** `https://commons.wikimedia.org/wiki/Lake_Titicaca` (**ROTA / HTML**)
- **gallery_image_4:** `https://commons.wikimedia.org/wiki/Category:Lake_Titicaca` (**ROTA / HTML**)

#### 3. Circuito Mágico del Agua (`circuito-magico-del-agua`)
- **cover_image_url:** `...CIRCUITO_MÁGICO_DEL_AGUA_-_Lima.jpg` (Válida).
- **gallery_image_1:** `...Circuito_mágico_del_agua...JPG` (Válida).
- **gallery_image_2:** `...Fuente_multicolor...jpg` (Válida).
- **gallery_image_3:** `...Circuito_agua_lima2.jpg` (Válida).
- **gallery_image_4:** `https://commons.wikimedia.org/wiki/Category:Circuito_Mágico_del_Agua` (**ROTA / HTML**)

> [!CAUTION]
> **El problema de HTML:** Las URLs de la galería 3 y 4 de varios destinos NO apuntan a una imagen `.jpg` o `.png`, sino a la **página web completa de Wikipedia**. Cuando Flutter intenta decodificar el HTML como si fuera un formato de imagen, falla silenciosamente.

---

## 4. Recomendaciones Exactas para la Siguiente Fase

Basado en el diagnóstico, la hoja de ruta para la Fase 4C.2 (Ejecución) debe ser:

1. **Limpieza de Assets:** 
   - Ejecutar la eliminación física de las 6 imágenes mock y la imagen del post-onboarding en `assets/images/`.
2. **Mapping Cloudinary (Estrategia Sin Secretos):** 
   - Crear `data/cloudinary_image_mapping.csv` utilizando la API pública de Fetch de Cloudinary (`res.cloudinary.com/demo/image/fetch/w_800,h_600,c_fill/`) combinada con URLs de alta calidad de Unsplash. Esto evita registrar cuentas, exponer secretos y usar `.env`.
3. **Limpieza de DB/CSV:** 
   - Construir el script de Python que respalde el CSV, reemplace los `cover_image_url` por los de Cloudinary Fetch, y **elimine/limpie** las galerías 3 y 4 que actualmente inyectan HTML malicioso para el parser visual.
4. **Fallback Visual Robusto:** 
   - Instalar `cached_network_image` en Flutter.
   - Refactorizar `AdaptiveDestinationImage` para erradicar el uso de `SizedBox.shrink()` en el `errorBuilder`, asegurando que toda imagen fallida renderice el ícono de las montañas grises.

---

## 5. Confirmaciones de Seguridad
- [x] **NO** se modificó código en Flutter ni en el Backend.
- [x] **NO** se borraron imágenes ni se alteró `pubspec.yaml`.
- [x] **NO** se tocaron registros en PostgreSQL.
- [x] **NO** se modificó el CSV actual.

## Conclusión
La auditoría revela que el problema visual no radica únicamente en URLs rotas, sino en la inyección de metadatos HTML en campos designados para recursos binarios. La limpieza estructural y la implementación del Fetch Público de Cloudinary descritas en las recomendaciones estabilizarán el componente al 100%.

**FASE 4C.2A CERRADA EXCITOSAMENTE. LISTO PARA AVANZAR A LA EJECUCIÓN.**
