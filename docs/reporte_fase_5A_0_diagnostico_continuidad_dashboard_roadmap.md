# Fase 5A.0 — Diagnóstico de continuidad del Dashboard y Roadmap restante PROXVEL

> **Modo:** Diagnóstico. Sin modificaciones de código.
> **Fecha:** 2026-06-15
> **Alcance:** Dashboard Admin, Backend FastAPI, App Flutter.

---

## 1. Resumen Ejecutivo

El MVP de PROXVEL tiene tres componentes en estados muy distintos de madurez:

- **Backend FastAPI**: completo y funcional. Todos los dominios críticos tienen endpoints reales, protegidos con JWT/RBAC.
- **Dashboard Admin (React/Vite/TS)**: funcional en los módulos core (métricas, destinos, multimedia, anuncios). Tiene dos módulos en estado placeholder explícito (Usuarios y Excel Import) y ausencia de analítica real.
- **App Flutter**: visualmente sólida, con lógica real de recomendaciones, auth JWT y Cloudinary. Sin embargo, contiene elementos hardcodeados disfrazados de personalización, botones rotos y una tab completa muerta (Rutas). El reporte de auditoría de vistas (`reporte_auditoria_vistas_frontend_ux.md`) ya documentó esto con precisión.

**El sistema puede generar un APK defendible hoy, pero necesita limpieza puntual antes de demo académica.**

---

## 2. Estado Actual del Dashboard Admin

### Módulos COMPLETOS y conectados con backend real

| Módulo | Ruta | Estado |
|---|---|---|
| Login / Auth JWT | `/login` | ✅ Completo — `POST /auth/login` + `GET /auth/me` |
| Métricas Overview | `/` (Home) | ✅ Completo — `GET /admin/metrics/overview` consume datos reales |
| Gráfico de cobertura | Home | ✅ Calculado desde métricas |
| System Status | Home | ✅ Ping a `GET /health` |
| Listado Destinos | `/destinos` | ✅ Completo — filtros por nombre/ciudad/portada |
| Detalle Destino | `/destinos/:id` | ✅ Completo — aspectos, ABSA, galería |
| Media Manager | `/destinos/:id/multimedia` | ✅ Completo — upload a Cloudinary, patch metadatos, soft-delete |
| Anuncios CRUD | `/anuncios` | ✅ Completo — GET/POST/PATCH/DELETE/imagen |
| Editor de Anuncios | `/anuncios/nuevo`, `/anuncios/:id` | ✅ Completo — formulario con upload de imagen de fondo |
| Configuración / Sesión | `/configuracion` | ✅ Completo — muestra rol, email, estado API, versión |

### Módulos PLACEHOLDER (funcionalidad visible pero no operativa)

| Módulo | Ruta | Estado | Razón |
|---|---|---|---|
| Gestión de Usuarios | `/usuarios` | ⚠️ Placeholder | Backend no tiene `GET /admin/users`. Lo documenta honestamente |
| Importar Excel | `/importar` | ⚠️ Placeholder | Backend no tiene `POST /admin/destinations/import`. Dropzone deshabilitado |
| Analítica de uso | Sección en Home | ⚠️ Placeholder | No existe endpoint ni instrumentación de eventos |

### Riesgos técnicos conocidos del Dashboard

1. **JWT en localStorage** — El `authStore.ts` almacena el token en `localStorage` (documentado como riesgo XSS aceptable para MVP; pendiente migrar a `cookies httpOnly` para producción).
2. **CORS** — No se auditó la config de CORS del backend para producción cloud. Puede ser issue al desplegar.
3. **Build / lazy loading** — El bundle no usa lazy loading; todo se carga en el inicio. Aceptable para dashboard interno de baja escala.
4. **super_admin real** — `danielmg2302@gmail.com` fue creado/actualizado como `super_admin`. **No validado aún en el dashboard** (pendiente de Fase 5A.1).

---

## 3. Estado Actual del Backend (FastAPI)

### Endpoints existentes (completos y activos)

| Dominio | Endpoints | Estado |
|---|---|---|
| Health | `GET /health` | ✅ |
| Auth | `POST /auth/login`, `GET /auth/me` | ✅ |
| Users | `POST /users`, `GET /users/{id}`, `PATCH /users/{id}`, `GET /users/demo`, `GET /users/{id}/traveler-profile`, `PUT/PATCH /users/{id}/traveler-profile` | ✅ |
| Destinations | `GET /destinations`, `GET /destinations/{id}` | ✅ |
| Destination Media | `GET /destinations/{id}/media`, `POST /destinations/{id}/media/upload`, `PATCH /destinations/{id}/media/{mid}`, `DELETE /destinations/{id}/media/{mid}` | ✅ con Cloudinary |
| Favorites | `GET /favorites`, `POST /favorites/{id}`, `DELETE /favorites/{id}`, `GET /favorites/check/{id}` | ✅ |
| Reviews | `POST /reviews`, `GET /reviews/destination/{id}`, `GET /reviews/user/{id}`, `GET /reviews/{id}`, `GET /reviews/pending` | ✅ |
| Recommendations | `GET /recommendations/me`, `GET /recommendations/contextual`, y variantes | ✅ |
| Tourism / Map | `GET /tourism/map-markers`, y 2 adicionales | ✅ |
| Admin Metrics | `GET /admin/metrics/overview` | ✅ |
| Admin Announcements | CRUD completo + upload imagen | ✅ |
| Admin Training | Batches, model-update-runs | ✅ |
| Announcements Public | `GET /announcements/active` | ✅ |

### Endpoints FALTANTES (requeridos por módulos pendientes)

| Endpoint | Módulo que lo necesita | Prioridad |
|---|---|---|
| `GET /admin/users` | Dashboard → Gestión de usuarios | POST-MVP |
| `PATCH /admin/users/{id}/role` | Dashboard → cambiar rol desde UI | POST-MVP |
| `PATCH /admin/users/{id}/status` | Dashboard → activar/desactivar desde UI | POST-MVP |
| `POST /admin/destinations/import` | Dashboard → Excel Import | POST-MVP |
| `POST /admin/destinations/import/confirm` | Dashboard → Excel Import | POST-MVP |
| `POST /analytics/events` | Analítica real | Futuro/Producción |
| `GET /admin/metrics/usage` | Analítica real | Futuro/Producción |

**Conclusión backend**: el backend cubre todo lo necesario para APK demo. No hay endpoint bloqueante sin implementar.

---

## 4. Estado Actual de la App Flutter

### Módulos COMPLETOS (conectados con backend real)

| Módulo | Estado |
|---|---|
| Auth (Login / Register / Auto-login / Restore session) | ✅ JWT real |
| Onboarding + Perfil de viajero | ✅ Backend real |
| Preferencias del viajero | ✅ Backend real |
| Recomendaciones (`/recommendations/me`) | ✅ Motor real |
| Detalle de destino (info, ABSA, aspectos) | ✅ Backend real |
| Favoritos (toggle, listado) | ✅ Backend real |
| Reseñas por destino | ✅ Backend real |
| Mis Reseñas | ✅ Backend real |
| Enviar feedback / reseña | ✅ Backend real |
| Búsqueda y filtros | ✅ Backend real + compat asíncrono |
| Mapa turístico | ✅ Backend real + manejo de GPS |
| Mock Fallback controlado (`USE_MOCK_FALLBACK`) | ✅ Implementado (default=false) |
| `API_BASE_URL` configurable por `--dart-define` | ✅ Implementado |

### Problemas CONFIRMADOS por auditoría de vistas

Fuente: `reporte_auditoria_vistas_frontend_ux.md`

| Problema | Vista | Severidad | Impacto |
|---|---|---|---|
| `ProfileSummaryCard` de "Para ti" completamente hardcodeada | `home/widgets/profile_summary_card.dart` | 🔴 Crítico | Contradice el discurso del recomendador |
| Botón "Editar perfil" es un `// TODO` muerto | Misma card | 🔴 Crítico | Dead affordance |
| Tab **Rutas** tiene 3 sub-tabs vacías con el mismo "Próximamente" | `routes_screen.dart` | 🔴 Crítico | 1/5 del nav principal sin función |
| CTA "Explorar destinos" en Favoritos navega a `/home` (ruta inexistente) | `favorites_screen.dart` | 🔴 Crítico | Botón roto |
| CTA "Explorar destinos" en Rutas navega a `/home` (ruta inexistente) | `routes_screen.dart` | 🔴 Crítico | Botón roto |
| Frase "Este destino es ideal para tu perfil" hardcodeada (igual para todos) | `why_for_me_tab_content.dart` | 🟠 Alto | Falsa personalización |
| "Factores que más influyen" con textos fijos | `why_for_me_tab_content.dart` | 🟠 Alto | Falsa personalización |
| Fallback `return 75` en `_findAspectScore` | `why_for_me_tab_content.dart` | 🟠 Alto | Dato inventado |
| `rankPosition = 1` fijo en `RankingHeaderCard` | `destination_detail_screen.dart` | 🟠 Alto | Falso ranking |
| `ForYouScreen` huérfano (no en router) | `for_you/for_you_screen.dart` | 🟡 Medio | Código muerto |
| Stat "Rutas" en Perfil (feature muerta) | `profile_screen.dart` | 🟡 Medio | Dato sin sentido |
| Tab "Opiniones" muestra `Usuario: U00001` en vez de nombre | `reviews_tab_content.dart` | 🟡 Medio | Dato técnico expuesto |
| Reseñas: sin nombre del autor, sin fecha, sin distribución de estrellas | Opiniones tab | 🟡 Medio | UX pobre |
| `flutter analyze`: 18 warnings (`withOpacity`, imports no usados, etc.) | Mapa principalmente | ⚪ Info | No bloquea APK |
| Anuncios internos (`/announcements/active`): **no integrados en Flutter** | No existe consumo | 🟠 Alto | Canal de comunicación muerto |

---

## 5. Fases Cerradas

| Fase | Descripción |
|---|---|
| 4C.2E | Cloudinary E2E validado |
| 4C.2F | Roles traveler/admin/super_admin formalizados |
| 4D.1 | Auditoría mapa turístico + overlay Rutas "Próximamente" |
| 4E | Cierre técnico MVP (QA integral) |
| 4F.1 | Correcciones críticas pre-APK (U000, mock fallback, env vars, password local) |
| 5A.1 (parcial) | Script `create_admin_user.py` actualizado a upsert; super_admin `danielmg2302@gmail.com` creado |

## 6. Fases PARCIALMENTE Cerradas

| Fase | Qué falta |
|---|---|
| 5A.1 | Validar login real en dashboard + confirmar rol super_admin visible |
| UX Flutter | Auditoría de vistas completada pero ninguna corrección aplicada aún |

---

## 7. Lista de Pendientes Clasificados

### 🔴 BLOQUEANTE ANTES DE APK

| # | Pendiente | Razón |
|---|---|---|
| 1 | Validar login dashboard con `danielmg2302@gmail.com` | Super_admin real debe funcionar antes de demostrar el sistema |
| 2 | Arreglar `context.go('/home')` → `/main` en Favoritos y Rutas | Botón roto = crash UX en demo |
| 3 | Eliminar o alimentar `ProfileSummaryCard` falsa de "Para ti" | Contradice el recomendador de la tesis |
| 4 | Quitar sub-tabs falsas de Rutas (dejar solo teaser único) | 3 tabs con el mismo "Próximamente" es indefendible |
| 5 | Arreglar `rankPosition = 1` hardcodeado | Muestra "#1" para todos los destinos |
| 6 | Quitar fallback `return 75` en `_findAspectScore` | Dato inventado visible en la tesis |
| 7 | Build APK debug (validar que compila sin errores fatales) | Necesario antes de demo física |

### 🟠 IMPORTANTE ANTES DE DEMO ACADÉMICA

| # | Pendiente | Razón |
|---|---|---|
| 8 | Eliminar `for_you_screen.dart` huérfano | Código muerto que confunde |
| 9 | Stat "Rutas" en Perfil → cambiar por "Reseñas" | Dato sin sentido |
| 10 | Hacer dinámicos los "Factores que más influyen" | Diferencial de la tesis |
| 11 | Integrar `GET /announcements/active` en Flutter (Home o inicio) | El canal de comunicación admin→app no existe |
| 12 | Cargar imágenes reales desde dashboard (al menos 3-5 destinos) | El demo necesita contenido visual real |
| 13 | Verificar que Flutter consume portadas reales de Cloudinary | Posible issue si `cover_image_url` no llega al modelo Flutter |
| 14 | Tab "Opiniones": mostrar nombre de autor en vez de ID | Dato técnico expuesto en demo |
| 15 | Desactivar `admin@proxvel.com` demo si existe en BD | Higiene de seguridad antes de demo |

### 🟡 POST-MVP (post-tesis o iteración siguiente)

| # | Pendiente |
|---|---|
| 16 | Excel Import real (requiere backend nuevo) |
| 17 | Gestión de usuarios desde dashboard (requiere backend nuevo) |
| 18 | Analítica real (requiere instrumentación de eventos) |
| 19 | QR de descarga APK |
| 20 | Ordenamiento en búsqueda (precio, distancia, compat) |
| 21 | Cluster de marcadores en mapa |
| 22 | Distribución de estrellas en tab Opiniones |
| 23 | Build APK release firmado |

### 🔵 FUTURO / PRODUCCIÓN

| # | Pendiente |
|---|---|
| 24 | Migrar JWT del dashboard de `localStorage` a `cookies httpOnly` |
| 25 | CORS seguro en backend (revisar orígenes permitidos) |
| 26 | Bundle dashboard con lazy loading |
| 27 | Landing page PROXVEL |
| 28 | Formulario solicitud APK por correo |
| 29 | iOS: validar permisos `Info.plist` para compilación en Xcode |
| 30 | `withOpacity` → `.withValues()` (18 warnings Flutter) |

### ⚪ NO NECESARIO (para este proyecto)

| # | Pendiente | Razón |
|---|---|---|
| 31 | Testing unitario/widget completo | Tiempo vs valor para MVP de tesis |
| 32 | CI/CD pipeline | Overkill para MVP local |

---

## 8. Endpoints Existentes (resumen ejecutivo)

```
Auth:           POST /auth/login, GET /auth/me
Users:          POST, GET, PATCH /users + traveler-profile
Destinations:   GET /destinations, GET /destinations/{id}
Media:          GET/POST/PATCH/DELETE /destinations/{id}/media(...)
Favorites:      GET/POST/DELETE /favorites(...)
Reviews:        POST/GET /reviews(...)
Recommendations: GET /recommendations/me, /contextual
Tourism:        GET /tourism/map-markers
Admin Metrics:  GET /admin/metrics/overview
Admin Announcements: CRUD + imagen
Admin Training: batches, model-update-runs
Public Announcements: GET /announcements/active
```

## 9. Endpoints Faltantes Críticos

```
GET  /admin/users                          ← para módulo Usuarios del dashboard
PATCH /admin/users/{id}/role               ← para módulo Usuarios del dashboard
POST /admin/destinations/import            ← para Excel Import
GET  /admin/metrics/usage                  ← para analítica real
POST /analytics/events                     ← para analítica real
```

Ninguno es bloqueante antes del APK.

---

## 10. Riesgos Pendientes

| Riesgo | Severidad | Estado |
|---|---|---|
| `ProfileSummaryCard` falsa disfrazada de personalización | 🔴 Crítico | Pendiente de corrección |
| Botones rotos (`/home` inexistente) | 🔴 Crítico | Pendiente |
| `rankPosition = 1` siempre | 🔴 Crítico | Pendiente |
| Anuncios no integrados en Flutter | 🟠 Alto | Pendiente |
| Portadas reales Cloudinary no validadas en Flutter | 🟠 Alto | Sin confirmar E2E |
| JWT dashboard en localStorage | 🟡 Medio | Aceptado para MVP; pendiente para producción |
| iOS no validado físicamente | 🟡 Medio | Sin dispositivo |
| 18 warnings Flutter (`withOpacity`) | ⚪ Bajo | No bloquea |

---

## 11. Roadmap Recomendado (con orden exacto)

```text
5A.1  — Validación real del dashboard con super_admin danielmg2302@gmail.com
        [BLOQUEANTE: confirmar que el sistema admin funciona de punta a punta]

5B    — Correcciones UX Flutter (lo muerto, lo roto y lo falso)
        - Arreglar /home → /main
        - Quitar ProfileSummaryCard falsa o alimentarla con datos reales
        - Quitar sub-tabs redundantes de Rutas
        - Arreglar rankPosition y fallback 75
        - Eliminar for_you_screen.dart huérfano
        [BLOQUEANTE: sin esto, la demo académica queda indefendible]

5C    — Carga real de contenido: imágenes desde dashboard a destinos
        - Subir portadas reales a al menos 5-8 destinos
        - Verificar que Flutter muestra la portada real de Cloudinary
        - Crear 1-2 anuncios reales en el dashboard
        [IMPORTANTE: el app vacío de contenido real no impresiona en demo]

5D    — Integración de Anuncios internos en Flutter
        - Consumir GET /announcements/active
        - Mostrar banner en Home o en inicio de sesión
        [IMPORTANTE: conecta el canal admin↔app]

5E    — Build APK debug y validación en dispositivo físico Android
        - flutter build apk --dart-define=API_BASE_URL=http://<IP>:8000/api/v1
        - Instalar en dispositivo real
        - Validar flujo completo: registro → recomendaciones → detalle → reseña
        [BLOQUEANTE si el objetivo es entregar APK]

5F    — Higiene final pre-demo
        - Desactivar admin@proxvel.com demo (si existe)
        - Documentar traveler@proxvel.com como cuenta de prueba
        - Revisar mensaje de error en caso de backend offline
        [IMPORTANTE para demo académica profesional]

5G    — Excel Import real (si se decide implementar)
        - Requiere 2 endpoints nuevos en backend
        - Solo si hay tiempo; no bloquea APK ni demo

5H    — Landing page PROXVEL
        - Separada del dashboard y la app
        - Post-MVP / producción
```

---

## 12. Qué NO Hacer Todavía

- ❌ No construir gestión de usuarios desde dashboard (requiere backend nuevo + no es necesario para APK).
- ❌ No implementar Excel Import real (misma razón).
- ❌ No crear analítica de uso (requiere instrumentación de eventos + tiempo).
- ❌ No hacer build APK release firmado todavía (primero debug y validación).
- ❌ No crear landing page todavía (post-MVP).
- ❌ No migrar JWT a cookies httpOnly todavía (producción real).
- ❌ No refactorizar arquitectura Flutter (riesgo alto sin beneficio claro para demo).

---

## 13. Fase Inmediata Recomendada

**Fase 5A.1 — Validación real dashboard con `super_admin` real**

Objetivo: confirmar que `danielmg2302@gmail.com` puede:
1. Hacer login en el dashboard.
2. Ver su nombre y rol `super_admin` en Settings.
3. Ver métricas reales en Home.
4. Navegar a Destinos y ver el catálogo.
5. Abrir Media Manager y subir una imagen real a Cloudinary.
6. Crear un anuncio interno.

Luego de confirmar 5A.1, continuar con **5B — Correcciones UX Flutter**.

---

## 14. Veredicto

**VEREDICTO: LISTO PARA CONTINUAR — con observaciones críticas**

El sistema técnico está maduro:
- El backend es sólido y completo para el alcance del MVP.
- El dashboard funciona con datos reales.
- La app Flutter consume el backend correctamente.

Sin embargo, **la app tiene problemas de honestidad de datos** que deben corregirse antes de la demo académica: contenido falso disfrazado de personalización, botones rotos y navegación rota. Estos no son bugs técnicos sino deuda de contenido y UX que puede hacer que la defensa de la tesis se vea inconsistente.

**La ruta crítica hacia demo es: 5A.1 → 5B → 5C → 5D → 5E.**
