# PROXVEL — Auditoría de Vistas Frontend: Redundancia, Contenido, Estructura y UX/UI

> **Modo:** diagnóstico (sin cambios de código en este documento).
> **Alcance:** todas las vistas de `proxvel_app/lib/views` + widgets compartidos.
> **Fecha:** 2026-06-15.
> **Enfoque pedido:** redundancias, contenido que no aporta, problemas de estructura, jerarquía visual, qué falta o se puede potenciar, vistas que sobran o deberían cambiar, buenas prácticas UI/UX.

---

## 1. Resumen ejecutivo

La app está **visualmente cuidada** (tema consistente, headers con gradiente, cards con sombra, empty states, bottom sheets). El problema **no es el estilo, es la honestidad y el propósito del contenido**: varias vistas muestran **datos inventados/hardcodeados disfrazados de personalización**, hay **una pestaña del menú principal que no existe** (Rutas = "Próximamente"), **botones que no hacen nada**, y **navegación rota** a una ruta inexistente.

Para una app de recomendación (y para defender una tesis), el riesgo mayor es que **lo que parece personalizado en realidad es fijo**. Eso hay que limpiarlo antes que cualquier detalle estético.

**Top 5 de cosas a corregir primero:**
1. `ProfileSummaryCard` de "Para ti" está **completamente hardcodeado** (fechas, clima, chips) y su botón "Editar perfil" es un `// TODO` muerto.
2. Pestaña **Rutas** del bottom nav: todo es "Próximamente" con 3 sub-tabs idénticas → ocupa 1/5 de la navegación sin función.
3. `context.go('/home')` (en Favoritos y Rutas) apunta a una **ruta que no existe** (`/home` no está en el router; es `/main`) → botón roto.
4. Tab "¿Por qué para mí?": "Factores que más influyen" y la frase "Este destino es ideal para tu perfil" están **hardcodeados** para todos los destinos.
5. `ForYouScreen` es un **placeholder muerto** ("Recomendaciones Simuladas") que ya no se usa.

---

## 2. Mapa de navegación actual y problema de arquitectura de información (IA)

```
Bottom Nav (5 tabs)
├── Home ──┬── Tab "Explorar"   (HomeExploreContent)
│          └── Tab "Para ti"    (HomeForYouContent)
├── Mapa
├── Favoritos
├── Rutas   ← ⚠️ 100% "Próximamente" (3 sub-tabs vacías idénticas)
└── Perfil ──> Editar / Preferencias / Mis reseñas / Sobre / Logout
```

**Problemas de IA:**
- **Doble capa de tabs**: el bottom nav + tabs internos en Home (Explorar/Para ti) y en Rutas (3 tabs). El usuario navega tabs dentro de tabs. Aceptable en Home, **inútil en Rutas** (las 3 sub-tabs muestran lo mismo).
- **1 de 5 destinos del menú no existe** (Rutas). Un menú principal donde el 20% no hace nada transmite producto inacabado.
- **Recomendación:** para el MVP/APK, **bajar a 4 tabs** (Home, Mapa, Favoritos, Perfil) y mover "Rutas" a un acceso secundario marcado como "Próximamente", o quitarlo. Mejor 4 sólidas que 5 con una vacía.

---

## 3. ⛔ Contenido falso / hardcodeado disfrazado de dinámico (lo más importante)

Estos elementos **aparentan ser personalizados o reales pero son fijos**. Es lo que pediste detectar ("elementos por estar, no por cumplir un propósito").

| Vista / archivo | Elemento | Evidencia | Por qué está mal | Recomendación |
|---|---|---|---|---|
| `home/widgets/profile_summary_card.dart` | **Toda la tarjeta** ("Marzo 2026", "Clima templado y variable", chips "Afluencia media", "💰 Medio", "Paisaje"…) | l.66-176 todo literal | Es la tarjeta de la pestaña **"Para ti"** (la personalizada) y no usa el perfil real del usuario | Alimentar con `ProfileController.profile` o **eliminarla** |
| `home/widgets/profile_summary_card.dart` | Botón "Editar perfil" | l.190-191 `// TODO: Edit profile logic` | **No hace nada** al tocarlo | Enlazar a `/profile/preferences` o quitar |
| `destination/widgets/why_for_me_tab_content.dart` | Frase "Este destino es ideal para tu perfil de viajero" | l.55-63 fija | Se muestra **igual** para un destino al 95% y uno al 50% | Generar según `compatibilityPercentage` o quitar |
| `why_for_me_tab_content.dart` | "Factores que más influyen" (Clima favorable / Aforo moderado + descripciones) | l.118-140 textos fijos | Dice "compatible con tu preferencia templada / tolerancia baja" **sin leer el perfil real** | Derivar de `travelerProfile` + aspectos reales |
| `why_for_me_tab_content.dart` | `_findAspectScore` fallback | l.258 `return 75` | Cuando falta el dato, **inventa 75%** en los círculos de métrica | Mostrar "—" / ocultar el círculo |
| `destination_detail_screen.dart` | `rankPosition = 1` | l.~307 fijo | El `RankingHeaderCard` muestra **"#1" siempre** | Pasar el índice real desde la lista de recomendaciones |
| `destination/widgets/traveler_profile_summary_card.dart` | Fallback de preferencias | l.131-135 ("Templado/Baja/Cultural y aventura") | Si no hay perfil, muestra preferencias falsas como si fueran del usuario | Mostrar estado vacío "Completa tu perfil" |

> **Mensaje claro:** la pestaña "Para ti" y la pestaña "¿Por qué para mí?" son justo donde el usuario espera personalización, y son las que más contenido fijo tienen. Esto contradice el discurso del recomendador.

---

## 4. 🔌 Elementos rotos o sin acción (dead affordances)

| Vista | Elemento | Evidencia | Efecto |
|---|---|---|---|
| `favorites_screen.dart` | CTA "Explorar destinos" (empty state) | l.54 `context.go('/home')` | **Ruta inexistente** → navegación rota (debe ser `/main`) |
| `routes_screen.dart` | CTA "Explorar destinos" | l.155 `context.go('/home')` | Igual, **rota** |
| `home/widgets/profile_summary_card.dart` | "Editar perfil" | l.190 `// TODO` | No hace nada |
| `why_for_me_tab_content.dart` | Botón info (ⓘ) "Aspectos turísticos" | l.151-154 onTap vacío | Botón que invita a tocar y no responde |
| `home_explore_content.dart` | "Ver más" de "Escapadas según tu tiempo" | l.158 `onSeeMore: () {}` | Link muerto |
| `home_explore_content.dart` | Botón "tune" (filtros) de la barra de búsqueda | l.220-231 va a `/search` | Debería abrir el sheet de filtros, no solo navegar (el ícono promete filtros) |

---

## 5. ♻️ Redundancias

### Código / pantallas duplicadas
| Redundancia | Detalle | Recomendación |
|---|---|---|
| **2 tarjetas de "resumen de perfil"** | `home/widgets/profile_summary_card.dart` (falsa) vs `destination/widgets/traveler_profile_summary_card.dart` (real) | Unificar en un solo widget que reciba el `TravelerProfileModel` |
| **`ForYouScreen` huérfano** | `for_you/for_you_screen.dart` = "Recomendaciones Simuladas", no está en el router; la "Para ti" real es `HomeForYouContent` | **Eliminar** el archivo |
| **Feature "Rutas" completa muerta** | `routes_screen` + `routes_controller` + `route_service` + `route_model` + `route_card` + `mock_route_data_source` → solo renderizan "Próximamente" | Aislar/retirar del MVP hasta implementarla |
| **3 cards de destino** | `DestinationCard`, `TrendingDestinationCard`, `DestinationRecommendationCard` | Contextos distintos (grid / carrusel / ranking) → **OK**, pero comparten imagen+gradiente+favorito; extraer subcomponentes |
| `_AnimatedMapMarker` duplicado en 2 mapas | ✅ **Ya resuelto** (extraído a `core/widgets/maps/animated_map_marker.dart`) | — |

### Contenido redundante
- **Stat "Rutas" en Perfil** (`profile_screen.dart` l.96-100): cuenta una feature que no existe → siempre 0/mock. Reemplazar por "Reseñas" (que sí existe vía `/reviews/user`).
- **Barra de búsqueda** aparece en Home (campo + botón) y se repite el header de búsqueda en `SearchResultsScreen`. Coherente, no es problema; solo unificar el placeholder ("¿A dónde viajas hoy?" está en ambos, bien).

---

## 6. Análisis vista por vista

### 🏠 Home → "Explorar" (`home_explore_content.dart`)
- **Bien:** carrusel auto-scroll con dots, búsquedas recientes, secciones claras, banner CTA que cambia a "Para ti".
- **Sobra / arreglar:** "Ver más" muerto en Escapadas (l.158); el botón de filtros no abre filtros.
- **Potenciar:** "Cerca de ti" usa `geolocator` (ya es dependencia) — confirmar que la distancia es real y no mock; permitir tocar "Ver más" para ir a búsqueda con esa ciudad.
- **Jerarquía:** correcta (búsqueda → momento → CTA → cerca → escapadas).

### 🏠 Home → "Para ti" (`home_for_you_content.dart`)
- **Bien:** título con conteo de lugares, cards de recomendación con índice, empty state con error real.
- **Crítico:** encabezada por `ProfileSummaryCard` **falso** (§3). Es lo primero que ve el usuario en su pestaña personalizada y es mentira.
- **Potenciar:** sustituir esa card por un resumen real (clima del mes del backend + preferencias reales) o quitarla y empezar directo por "Recomendados para ti".

### 🗺️ Mapa (`map_screen.dart`)
- **Bien:** FlutterMap + OSM, filtros por categoría, marcadores animados (ya deduplicados).
- **Potenciar:** clusterización si hay muchos marcadores; botón "mi ubicación".

### ❤️ Favoritos (`favorites_screen.dart`)
- **Bien:** grid 2 columnas, botón quitar con confirmación (bottom sheet), empty state.
- **Roto:** CTA del empty state va a `/home` inexistente (§4).
- **Potenciar:** ordenar (por compatibilidad/recientes); el corazón del overlay siempre está "activo" (rojo) → es claro que quita, pero un ícono de "quitar" (✕/trash) comunicaría mejor que un corazón lleno.

### 🧭 Rutas (`routes_screen.dart`)
- **Estado:** **no existe** como feature. 3 sub-tabs (Todas/Activas/Completas) renderizan el **mismo** "Próximamente".
- **Recomendación:** quitar del bottom nav para el MVP (o dejar 1 pantalla teaser sin tabs falsas). No mantener controller/service/mock de algo inexistente en producción.

### 👤 Perfil (`profile_screen.dart`)
- **Bien:** header, stats, resumen de preferencias **real** (usa `profile`), menú claro (editar/preferencias/reseñas/about/logout), logout con confirmación → `/welcome` (correcto).
- **Arreglar:** stat "Rutas" (feature muerta) → cambiar por "Reseñas".
- **Jerarquía:** buena.

### 📍 Detalle de destino (`destination_detail_screen.dart` + tabs)
- **Bien:** hero con gradiente, 3 tabs (¿Por qué para mí? / Sobre el destino / Opiniones), bottom bar de favorito (ya optimizado contra rebuilds).
- **Tab "Sobre el destino"** (`about_destination_tab_content.dart`): **excelente** — info oficial MINCETUR, descripción expandible, galería, actividades, accesibilidad, mapa, info práctica. Real y con propósito. ✅
- **Tab "¿Por qué para mí?"**: mezcla datos reales (explicación del backend, aspectos ABSA, footer del modelo) con **bloques fijos** (§3). Es el tab más importante para el discurso del recomendador y el que más maquillaje tiene.
- **Tab "Opiniones"**: muestra `Usuario: U00001` en vez de nombre; sin distribución de estrellas.

### 🔎 Búsqueda (`search_results_screen.dart`)
- **Bien:** header con campo + filtros con badge de conteo, chips de filtros activos, conteo de resultados, empty state contextual, sheet de filtros. UX sólida. ✅
- **Nota técnica:** la compatibilidad de cada resultado es real solo para destinos rankeados; el resto cae a mock (heredado). Aceptable, pero el orden "por compatibilidad" puede mezclar real con relleno.
- **Potenciar:** ordenamiento explícito (precio, distancia, compatibilidad) y guardar búsqueda.

### 🔐 Auth / Onboarding / Intro / Splash
- No se detectaron problemas de contenido falso en el escaneo (flujos funcionales). Revisión ligera; si quieres, los audito a fondo aparte.

---

## 7. Buenas prácticas UI/UX — checklist transversal

| Principio | Estado | Comentario |
|---|---|---|
| Cada elemento cumple un propósito | ❌ Parcial | Varias cards/factores son decorativos o falsos (§3) |
| Jerarquía visual clara | ✅ Mayormente | Headers y secciones bien priorizados |
| Consistencia de componentes | ⚠️ | 2 resúmenes de perfil, 3 cards de destino |
| Feedback al usuario (loading/empty/error) | ✅ | Buen manejo (`LoadingView`, `ProxvelEmptyState`, banners) |
| Affordances reales (todo lo tocable responde) | ❌ | Botones muertos (§4) |
| Navegación sin callejones | ❌ | `/home` roto; tab Rutas vacía |
| Honestidad de datos (no inventar) | ❌ | Fallbacks `75%`, rank `#1`, factores fijos |
| Densidad / espaciado | ✅ | Cómodo, no saturado |
| Accesibilidad (contraste, tamaños) | ⚠️ | Texto del footer del modelo a 10px es muy pequeño |

---

## 8. Qué AÑADIR para dar más potencial (por vista)

- **Para ti:** resumen del mes real (clima/aforo del backend) + “por qué te recomendamos esto” por encima de la lista.
- **Detalle / ¿Por qué para mí?:** factores de influencia **calculados** a partir de los aspectos con mayor peso para el perfil del usuario (eso es justo el diferencial de la tesis).
- **Opiniones:** nombre/inicial del autor, fecha, distribución de estrellas, y orden (recientes / mejor valoradas).
- **Favoritos:** ordenar y filtrar; comparación rápida de 2 destinos.
- **Búsqueda:** chips de búsquedas recientes dentro de la pantalla, orden configurable.
- **Mapa:** botón "centrar en mí" y clúster de marcadores.
- **Perfil:** stat "Reseñas"; logro/insignia por completar perfil (engagement).

---

## 9. Recomendaciones priorizadas

### 🔴 Quitar / arreglar antes del APK
1. Eliminar o alimentar con datos reales `ProfileSummaryCard` de "Para ti" (+ arreglar su botón muerto).
2. Quitar la pestaña **Rutas** del bottom nav (o dejar teaser sin tabs falsas).
3. Arreglar `context.go('/home')` → `/main` en Favoritos y Rutas.
4. Eliminar `for_you_screen.dart` (huérfano).
5. Volver dinámicos (o quitar) los bloques fijos del tab "¿Por qué para mí?" (frase ideal, factores, fallback 75, rank #1).

### 🟠 Siguiente iteración
6. Unificar las 2 tarjetas de resumen de perfil.
7. Stat "Rutas" → "Reseñas" en Perfil.
8. Activar/eliminar affordances muertas (info ⓘ, "Ver más", botón filtros).
9. Reseñas: nombre de autor + fecha + distribución.

### 🟡 Mejora continua
10. Ordenamientos en búsqueda/favoritos, clúster en mapa, caché de imágenes en disco, micro-animaciones.

---

## 10. Veredicto

- **¿La capa visual está bien?** Sí, el estilo es consistente y profesional.
- **¿El contenido cumple su propósito?** **No del todo.** El mayor problema no es el diseño sino que **partes clave fingen personalización** (Para ti, ¿Por qué para mí?) y hay **una sección entera muerta** (Rutas) y **botones/navegación rotos**.
- **Prioridad real:** primero **honestidad de datos + quitar lo muerto**, después estética. Si limpias el §3 y §4, la app pasa de "demo bonita con relleno" a "producto creíble".

> Todo lo de este documento es diagnóstico. Si quieres, puedo aplicar los arreglos del bloque 🔴 (son de bajo riesgo: borrar lo muerto, corregir rutas, cablear datos reales) en una tanda y validándolo con `flutter analyze`.
