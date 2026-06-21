# 📱 VISTAS — Análisis de Pantallas · PROXVEL App

---

## 📱 01 · SplashScreen
**Archivo:** `lib/views/splash/splash_screen.dart`  
**Ruta de navegación:** `/`  
**Propósito:** Pantalla de arranque que se muestra al abrir la app. Verifica si el usuario ya tiene una sesión activa guardada para decidir a dónde redirigirlo, sin necesidad de que el usuario haga nada.

### 🧩 Elementos visuales
- Fondo color gris claro (`#F9FAFB`)
- `CircularProgressIndicator` azul (`#2563EB`) centrado en pantalla
- Texto **"Verificando sesión..."** debajo del spinner

### 🔗 Navegación
- Si la sesión se restaura exitosamente → navega a `/main`
- Si no hay sesión activa → navega a `/welcome`

### ⚙️ Servicios / APIs
- `AuthController.restoreSession()` — intenta recuperar el token guardado y validar la sesión del usuario

### 🔄 Estados de la pantalla
- **Único estado visible:** loading con spinner mientras se verifica la sesión (mínimo 500 ms de delay)
- No tiene estado de error ni vacío; la redirección ocurre siempre

---

## 📱 02 · IntroScreen
**Archivo:** `lib/views/intro/intro_screen.dart`  
**Ruta de navegación:** `/intro`  
**Propósito:** Pantalla de introducción de la app. Actualmente es un placeholder básico que simplemente muestra el nombre de la app y un botón para continuar. Está pensada para mostrar slides o presentación de la app en futuras versiones.

### 🧩 Elementos visuales
- Texto grande **"PROXVEL INTRO"** centrado
- Botón **"Continuar"**

### 🔘 Botones y acciones
| Botón / Elemento | Acción que realiza |
|---|---|
| Continuar | Navega a `/welcome` (pantalla de bienvenida) |

### 🔗 Navegación
- Botón "Continuar" → `/welcome`

### 🔄 Estados de la pantalla
- **Único estado:** estático, sin lógica de carga ni error

> ⚠️ **Nota:** Esta pantalla es un placeholder. No está vinculada directamente desde el flujo principal (el `SplashScreen` navega a `/welcome` directamente). La ruta `/intro` existe en el router pero no se usa en el flujo normal aún.

---

## 📱 03 · WelcomeScreen
**Archivo:** `lib/views/auth/welcome_screen.dart`  
**Ruta de navegación:** `/welcome`  
**Propósito:** Pantalla de bienvenida que se muestra a los usuarios que no tienen sesión activa. Es la puerta de entrada al flujo de autenticación; ofrece las opciones de iniciar sesión, registrarse o conectarse con redes sociales.

### 🧩 Elementos visuales
- Wrapper de layout de autenticación (`AuthLayoutWrapper`) con imagen/fondo de fondo
- Badge con el texto **"PROXVEL"** en la parte superior
- Título en dos líneas: `"Comienza tu"` (normal) + `"próxima aventura"` (bold), en blanco sobre el fondo
- Subtítulo descriptivo: *"Descubre destinos increíbles recomendados solo para ti."*
- Botón principal **"Iniciar Sesión"** (`ProxvelButton`)
- Separador con texto **"O conéctate con"**
- Dos botones de autenticación social: **Google** y **GitHub** (con íconos SVG)
- Link inferior: `"¿No tienes cuenta? Regístrate →"`

### 🔘 Botones y acciones
| Botón / Elemento | Acción que realiza |
|---|---|
| Iniciar Sesión | Navega a `/login` |
| Botón Google | Placeholder (sin implementar aún) |
| Botón GitHub | Placeholder (sin implementar aún) |
| "Regístrate →" | Navega a `/register` |

### 🔗 Navegación
- `"Iniciar Sesión"` → `/login`
- `"Regístrate"` → `/register`

### 🔄 Estados de la pantalla
- **Único estado:** estático, no carga datos ni muestra errores

### ⚙️ Widgets reutilizables
- `AuthLayoutWrapper` — envuelve todas las pantallas de auth con un diseño común
- `ProxvelButton` — botón primario estilizado del design system
- `SocialAuthButton` — botón de autenticación social con ícono SVG

---

## 📱 04 · LoginScreen
**Archivo:** `lib/views/auth/login_screen.dart`  
**Ruta de navegación:** `/login`  
**Propósito:** Pantalla de inicio de sesión. Permite al usuario autenticarse con email y contraseña. Incluye validaciones en tiempo real, manejo de errores del servidor y opción de recordar la sesión.

### 🧩 Elementos visuales
- Layout `AuthLayoutWrapper` con título **"¡Bienvenido de nuevo!"** y subtítulo *"Continua tu aventura"*
- Botón de regresar (flecha atrás)
- Campo de texto **Email**
- Campo de texto **Contraseña** con toggle de visibilidad
- Banner de error rojo (aparece si el login falla) con ícono y mensaje descriptivo
- Checkbox **"Recordar sesión"**
- Botón principal **"Iniciar Sesión"** con spinner de carga
- Link **"¿Olvidaste tu contraseña?"** (sin implementar)
- Botones de auth social: **Google** y **GitHub**
- Link inferior **"¿No tienes una cuenta? Regístrate"**

### 🔘 Botones y acciones
| Botón / Elemento | Acción que realiza |
|---|---|
| Iniciar Sesión | Valida campos y llama a `AuthController.login()` |
| Checkbox "Recordar sesión" | Activa/desactiva el flag `_rememberMe` (local, no integrado aún) |
| ¿Olvidaste tu contraseña? | Placeholder (sin implementar) |
| Botón Google | Placeholder (sin implementar) |
| Botón GitHub | Placeholder (sin implementar) |
| "Regístrate" | Navega a `/register` |
| Flecha atrás | Regresa a la pantalla anterior |

### 📝 Formularios e inputs
| Campo | Tipo | Validación | Propósito |
|---|---|---|---|
| Email | text/email | Requerido — *"El correo es requerido"* | Identificador del usuario |
| Contraseña | password (oculto) | Requerido — *"La contraseña es requerida"* | Autenticación |

### 🔗 Navegación
- Login exitoso → `/main`
- `"Regístrate"` → `/register`
- Botón atrás → pantalla anterior

### ⚙️ Servicios / APIs
- `AuthController.login(email, password)` — envía credenciales al backend y obtiene token de acceso

### 🔄 Estados de la pantalla
- **Normal:** formulario vacío listo para llenar
- **Loading:** botón muestra spinner mientras se procesa el login
- **Error de campo:** mensaje debajo del input si está vacío
- **Error de servidor:** banner rojo con mensaje de error devuelto por la API
- **Éxito:** redirección automática a `/main`

### ⚙️ Widgets reutilizables
- `AuthLayoutWrapper` — layout compartido de autenticación
- `ProxvelTextField` — campo estilizado con soporte de error y toggle de contraseña
- `ProxvelButton` — botón primario con estado de carga integrado
- `SocialAuthButton` — botón de red social con ícono SVG

---

## 📱 05 · RegisterScreen
**Archivo:** `lib/views/auth/register_screen.dart`
**Ruta de navegación:** `/register`
**Propósito:** Registro de nuevos usuarios en dos pasos: primero datos personales (nombre, apellidos, email), luego creación de contraseña con validación en tiempo real.

### 🧩 Elementos visuales
- `AuthLayoutWrapper` con título "Crea una cuenta con nosotros."
- **Paso 1:** Indicador "Paso 1 de 2 - Datos Personales", caja informativa, campos Nombre / Apellidos / Email, botón Siguiente (deshabilitado si hay campos vacíos), botones sociales, link a login
- **Paso 2:** Indicador "Paso 2 de 2 - Crear Contraseña", campos Contraseña / Confirmar contraseña, checklist de requisitos en tiempo real con íconos ✅/⭕, checkbox de términos, botones Registrarme / Volver

### 🔘 Botones y acciones
| Botón / Elemento | Acción que realiza |
|---|---|
| Siguiente → | Avanza al paso 2 (solo si todos los campos del paso 1 tienen contenido) |
| Botón Google | Placeholder (sin implementar) |
| Botón GitHub | Placeholder (sin implementar) |
| "Iniciar sesión" | Navega a `/login` |
| Registrarme | Llama a `AuthController.register()` si todos los requisitos se cumplen y se aceptaron T&C |
| ← Volver | Regresa al paso 1 |

### 📝 Formularios e inputs
| Campo | Tipo | Validación | Propósito |
|---|---|---|---|
| Nombre | text (Title Case) | Requerido | Nombre del usuario |
| Apellidos | text (Title Case) | Requerido | Apellidos del usuario |
| Email | text | Requerido | Correo electrónico |
| Contraseña | password | Mín. 8 chars + 1 mayúscula + 1 número + 1 símbolo | Clave de acceso |
| Confirmar contraseña | password | Debe coincidir | Confirmación de clave |
| Checkbox términos | boolean | Debe estar marcado | Aceptación de T&C |

### 🔗 Navegación
- Registro exitoso → `/onboarding`
- `"Iniciar sesión"` → `/login`

### ⚙️ Servicios / APIs
- `AuthController.register(name, lastName, email, password)` — crea la cuenta en el backend

### 🔄 Estados de la pantalla
- **Paso 1 inválido:** botón Siguiente deshabilitado
- **Paso 2:** checklist de contraseña en tiempo real (verde/gris)
- **Loading:** spinner en botón "Registrarme"
- **Error:** SnackBar rojo con mensaje del servidor

---

## 📱 06 · OnboardingProfileScreen
**Archivo:** `lib/views/onboarding/onboarding_profile_screen.dart`
**Ruta de navegación:** `/onboarding`
**Propósito:** Wizard de 5 pasos para personalizar el perfil viajero del usuario recién registrado. Recopila presupuesto, días de viaje, clima preferido, tolerancia a multitudes e intereses. Al completar muestra una pantalla de éxito con cuenta regresiva de 5 segundos.

### 🧩 Elementos visuales
- **Intro (Paso 0):** Ilustración, chips (Presupuesto/Intereses/Clima), texto motivacional, botones Empezar / Omitir
- **Paso 1:** 3 opciones de presupuesto (Bajo/Medio/Alto) + contador de días (1–30) con botones flechas
- **Paso 2:** 3 opciones de clima con emoji (❄️ Frío / 🌤️ Templado / ☀️ Cálido)
- **Paso 3:** 3 opciones de tolerancia a multitudes (Bajo/Medio/Alto)
- **Paso 4:** Grid de 12 chips animados con íconos SVG (Naturaleza, Cultura, Gastronomía, Compras, Aventura, Playa, Urbano, Rural, Negocios, Académico, Relax, Familiar)
- **Pantalla de éxito:** ícono check dorado en anillos concéntricos, cuenta regresiva circular de 5s, link "Ir ahora"
- Barra de progreso lineal en pasos 1–4

### 🔘 Botones y acciones
| Botón | Acción que realiza |
|---|---|
| Empezar | Avanza al paso 1 |
| Omitir | Navega a `/main` sin guardar |
| Siguiente → | Avanza al siguiente paso (requiere selección) |
| ← Volver | Retrocede al paso anterior |
| Terminar | Guarda el perfil y muestra pantalla de éxito |
| "Ir ahora" | Navega a `/main` inmediatamente |

### 🔗 Navegación
- Omitir o completado → `/main`

### ⚙️ Servicios / APIs
- `OnboardingController.saveProfile(TravelerProfileModel, userId)` — guarda preferencias en el backend

### 🔄 Estados de la pantalla
- **Normal:** cada paso con sus opciones
- **Loading:** diálogo de carga al guardar
- **Error:** SnackBar rojo si falla el guardado
- **Éxito:** pantalla de felicitaciones con countdown

---

## 📱 07 · MainLayout
**Archivo:** `lib/views/main/main_layout.dart`
**Ruta de navegación:** `/main`
**Propósito:** Shell de navegación principal con barra inferior de 5 tabs. Usa `IndexedStack` para preservar el estado de cada tab al cambiar entre ellos.

### 🧩 Elementos visuales
- Contenido del tab activo (ocupa toda la pantalla)
- `ProxvelBottomNavigation` con 5 tabs: 🏠 Home · 🗺️ Mapa · ❤️ Favoritos · 🧭 Rutas · 👤 Perfil

### 🔘 Botones y acciones
| Tab | Vista que carga |
|---|---|
| 🏠 Home (0) | HomeScreen |
| 🗺️ Mapa (1) | MapScreen |
| ❤️ Favoritos (2) | FavoritesScreen |
| 🧭 Rutas (3) | RoutesScreen |
| 👤 Perfil (4) | ProfileScreen |

---

## 📱 08 · HomeScreen
**Archivo:** `lib/views/home/home_screen.dart`
**Ruta de navegación:** *(Tab 0 del MainLayout)*
**Propósito:** Pantalla principal con dos tabs: "Explorar" (catálogo general) y "Para ti" (recomendaciones personalizadas por IA). Muestra anuncios de inicio en overlay al entrar.

### 🧩 Elementos visuales
- `HomeHeader` con saludo al usuario
- Barra de tabs pegajosa: **Explorar** y **Para ti**
- `HomeExploreContent` — lista/grid de destinos del catálogo
- `HomeForYouContent` — recomendaciones IA basadas en el perfil
- `AnnouncementModalOverlay` — overlay de anuncio `app_start` (aparece una vez por sesión)

### 🔘 Botones y acciones
| Elemento | Acción que realiza |
|---|---|
| Tab "Explorar" | Muestra destinos generales |
| Tab "Para ti" | Muestra recomendaciones IA |
| Card de destino | Navega a `/destination/:id` |
| Campo de búsqueda (en header) | Navega a `/search` |
| Cerrar anuncio | Llama a `AnnouncementController.dismiss(id)` |

### ⚙️ Servicios / APIs
- `HomeController.loadDestinations()` — destinos para Explorar
- `RecommendationController.loadRecommendations()` — recomendaciones para "Para ti"
- `AnnouncementController.load(placement: 'app_start')` — anuncio de inicio

### 🔄 Estados de la pantalla
- Loading / Con datos / Vacío / Con anuncio superpuesto

---

## 📱 09 · FavoritesScreen
**Archivo:** `lib/views/favorites/favorites_screen.dart`
**Ruta de navegación:** `/favorites` *(Tab 2 del MainLayout)*
**Propósito:** Grid de destinos guardados como favoritos. Permite eliminarlos mediante un bottom sheet de confirmación.

### 🧩 Elementos visuales
- Header degradado con título "Mis Favoritos" y contador
- Grid 2 columnas de `DestinationCard` con botón corazón rojo
- Bottom sheet de confirmación con botones "Cancelar" / "Quitar"
- Estado vacío con botón "Explorar destinos"

### 🔘 Botones y acciones
| Elemento | Acción que realiza |
|---|---|
| Card de destino | Navega a `/destination/:id` |
| ❤️ Ícono rojo en card | Abre bottom sheet de confirmación |
| "Quitar" (bottom sheet) | Llama a `FavoritesController.toggleFavorite(id)` |
| "Explorar destinos" | Navega a `/main` |

### ⚙️ Servicios / APIs
- `FavoritesController.loadFavorites()` — carga favoritos
- `FavoritesController.toggleFavorite(id)` — agrega/quita favorito

### 🔄 Estados de la pantalla
- Loading / Vacío / Con datos

---

## 📱 10 · RoutesScreen
**Archivo:** `lib/views/routes/routes_screen.dart`
**Ruta de navegación:** `/routes` *(Tab 3 del MainLayout)*
**Propósito:** Sección de rutas turísticas. **Actualmente es un placeholder** con mensaje "Próximamente".

### 🧩 Elementos visuales
- Header degradado con título "Mis Rutas"
- `ProxvelEmptyState` con mensaje "Próximamente"
- Botón "Explorar destinos"

### 🔄 Estados de la pantalla
- Único estado: placeholder estático

> ⚠️ **Nota:** Funcionalidad pendiente de implementar.

---

## 📱 11 · ProfileScreen
**Archivo:** `lib/views/profile/profile_screen.dart`
**Ruta de navegación:** `/profile` *(Tab 4 del MainLayout)*
**Propósito:** Perfil del usuario con estadísticas, resumen de preferencias y menú de acciones.

### 🧩 Elementos visuales
- `ProfileHeader` con nombre y email
- `ProfileStatsRow`: contadores de Favoritos, Reseñas y Recomendaciones
- `PreferencesSummaryCard` (si hay perfil guardado)
- `ProfileMenuSection` con opciones de menú
- Versión de la app "PROXVEL v1.0.0"
- Banner de error si falla la carga

### 🔘 Botones y acciones
| Menú | Acción que realiza |
|---|---|
| Editar perfil | Navega a `/profile/edit` |
| Mis preferencias | Navega a `/profile/preferences`, recarga perfil al volver |
| Mis reseñas | Navega a `/profile/my-reviews` |
| Acerca de PROXVEL | Abre `AboutProxvelSheet` (bottom sheet) |
| Cerrar sesión | Bottom sheet de confirmación → `AuthController.logout()` → `/welcome` |

### ⚙️ Servicios / APIs
- `ProfileController.loadProfileData()`
- `MyReviewsController.loadUserReviews(user)`
- `AuthController.logout()`

### 🔄 Estados de la pantalla
- Loading / Con datos / Error

---

## 📱 12 · EditProfileScreen
**Archivo:** `lib/views/profile/edit_profile_screen.dart`
**Ruta de navegación:** `/profile/edit`
**Propósito:** Edición de nombre y apellidos del usuario. El email es de solo lectura.

### 🧩 Elementos visuales
- AppBar "Editar perfil" con flecha atrás
- Avatar circular con botón de cámara (sin implementar)
- Campos: Nombre, Apellidos, Email (solo lectura)
- Botón "Guardar cambios" con spinner

### 📝 Formularios e inputs
| Campo | Tipo | Propósito |
|---|---|---|
| Nombre | text | Nombre del usuario |
| Apellidos | text | Apellidos del usuario |
| Email | text (readOnly) | Solo visualización |

### ⚙️ Servicios / APIs
- `AuthController.updateUserProfile(name, lastName, email)`

### 🔄 Estados de la pantalla
- Normal / Loading / Éxito (SnackBar verde + regresa)

---

## 📱 13 · PreferencesScreen
**Archivo:** `lib/views/profile/preferences_screen.dart`
**Ruta de navegación:** `/profile/preferences`
**Propósito:** Ver y editar preferencias de viaje: presupuesto, días, clima, tolerancia a multitudes e intereses (máx. 5). Incluye switch maestro para ordenamiento IA global.

### 🧩 Elementos visuales
- AppBar "Mis Preferencias" con ícono de editar
- Switch "Aplicar IA en toda la app" (efecto inmediato)
- Secciones de selección (chips): Presupuesto / Días / Clima / Tolerancia / Intereses
- Botones "Guardar Preferencias" y "Cancelar" (modo edición)

### 🔘 Botones y acciones
| Elemento | Acción que realiza |
|---|---|
| Ícono editar | Activa el modo edición |
| Switch IA | Llama a `ProfileController.setApplyAiGlobally(val)` inmediatamente |
| Guardar Preferencias | Llama a `ProfileController.updatePreferences()` |
| Cancelar | Restaura valores y sale del modo edición |

### ⚙️ Servicios / APIs
- `ProfileController.updatePreferences(TravelerProfileModel)`
- `ProfileController.setApplyAiGlobally(bool)`

### 🔄 Estados de la pantalla
- Vista (solo lectura) / Edición activa / Guardando / Error

---

## 📱 14 · MyReviewsScreen
**Archivo:** `lib/views/profile/my_reviews_screen.dart`
**Ruta de navegación:** `/profile/my-reviews`
**Propósito:** Historial de reseñas enviadas por el usuario.

### 🧩 Elementos visuales
- AppBar "Mis reseñas" con flecha atrás
- Lista de `MyReviewCard`
- Estado vacío: "Aún no has enviado reseñas"
- Estado de error con botón "Reintentar"

### ⚙️ Servicios / APIs
- `MyReviewsController.loadUserReviews(user)`

### 🔄 Estados de la pantalla
- Loading / Vacío / Error (con botón Reintentar) / Con datos

---

## 📱 15 · SearchResultsScreen
**Archivo:** `lib/views/search/search_results_screen.dart`
**Ruta de navegación:** `/search?q={query}`
**Propósito:** Búsqueda y filtrado de destinos. Soporta búsqueda por texto, filtros avanzados y ordenamiento por compatibilidad IA.

### 🧩 Elementos visuales
- Header degradado con campo de búsqueda, botón de filtros (badge con conteo), toggle "Ordenar por IA"
- Aviso si se activa IA sin perfil configurado
- Chips de filtros activos (horizontal scroll)
- Lista de `SearchResultCard` con contador de resultados

### 🔘 Botones y acciones
| Elemento | Acción que realiza |
|---|---|
| Campo de búsqueda | Busca al presionar Enter |
| Botón X (limpiar) | Limpia campo y relanza búsqueda |
| Botón filtros | Abre `SearchFilterSheet` (bottom sheet) |
| Switch IA | Activa/desactiva ordenamiento por compatibilidad |
| "Completar" (aviso IA) | Navega a `/profile/preferences` |
| Card de resultado | Navega a `/destination/:id?source=search` |

### ⚙️ Servicios / APIs
- `SearchController.search(filters, aiSort, hasProfile)`
- `ProfileController.loadProfileData()`

### 🔄 Estados de la pantalla
- Loading / Sin resultados / Con resultados / IA sin perfil

---

## 📱 16 · DestinationDetailScreen
**Archivo:** `lib/views/destination/destination_detail_screen.dart`
**Ruta de navegación:** `/destination/:id?source={source}`
**Propósito:** Detalle completo de un destino. Imagen hero expandible, información general y tres tabs cuyo orden varía según el origen (catálogo vs recomendación IA).

### 🧩 Elementos visuales
- `SliverAppBar` con imagen hero (300px), degradado, nombre y ubicación superpuestos
- Botones flotantes: ← regresar y ❤️ favorito en círculos blancos
- Badges: categoría, calificación ★, días estimados
- Selector de 3 tabs con indicador animado:
  - "Sobre el destino" · "Opiniones" · "¿Por qué para mí?"
- Barra inferior fija: botón "Añadir / En favoritos" (animado según estado)

### 🔘 Botones y acciones
| Elemento | Acción que realiza |
|---|---|
| ← Atrás | Regresa a la pantalla anterior |
| ❤️ (header y barra inferior) | `FavoritesController.toggleFavorite(id)` |
| Tabs | Cambia el contenido mostrado |

### 🔗 Navegación
- Orden de tabs según `source`: `explore/search` → [Sobre, Opiniones, IA] · `ai_recommendation/ai_search` → [IA, Sobre, Opiniones]

### ⚙️ Servicios / APIs
- `DestinationController.loadDestination(id)` — datos del destino, tourismo y reseñas
- `FavoritesController.toggleFavorite(id)`

### 🔄 Estados de la pantalla
- Loading (pantalla completa) / Con datos (con tabs)

---

## 📱 17 · FeedbackScreen
**Archivo:** `lib/views/feedback/feedback_screen.dart`
**Ruta de navegación:** `/feedback/:destinationId`
**Propósito:** Formulario para calificar y reseñar la experiencia en un destino. El botón de envío se habilita solo cuando todos los campos tienen valor.

### 🧩 Elementos visuales
- Header degradado "Calificar experiencia"
- `RatingSelector` — selector de estrellas interactivo
- 6 `FeedbackOptionChip` para tipo de experiencia (Visita / Alojamiento / Gastronomía / Aventura / Cultural / Familiar)
- Área de texto multilínea para comentario
- Botón "Enviar feedback" con animación habilitado/deshabilitado
- Pantalla de éxito con ícono verde y botón "Volver al destino"

### 📝 Formularios e inputs
| Campo | Tipo | Validación |
|---|---|---|
| Rating | estrellas (0–5) | > 0 requerido |
| Tipo de experiencia | chip único | Requerido |
| Comentario | text multilínea | No vacío requerido |

### ⚙️ Servicios / APIs
- `FeedbackController.submitFeedback(FeedbackModel)`
- `AuthController.currentUser` — ID del usuario

### 🔄 Estados de la pantalla
- Normal (incompleto) / Completo (botón activo) / Enviando / Éxito / Error (SnackBar)

---

## 📱 18 · MapScreen
**Archivo:** `lib/views/map/map_screen.dart`
**Ruta de navegación:** `/map` *(Tab 1 del MainLayout)*
**Propósito:** Mapa interactivo con todos los destinos turísticos usando OpenStreetMap. Permite filtrar marcadores por categoría.

### 🧩 Elementos visuales
- AppBar "Mapa Turístico"
- Barra horizontal de `FilterChip` con categorías ("Todos" + dinámicas)
- Mapa OpenStreetMap centrado en Perú (zoom 5)
- `AnimatedMapMarker` por cada destino

### 🔘 Botones y acciones
| Elemento | Acción que realiza |
|---|---|
| Chip de categoría | Filtra marcadores |
| Marcador de destino | Navega a `/destination/:id` |

### ⚙️ Servicios / APIs
- `TourismMapController.loadMarkers()`
- `TourismMapController.setCategory(category)`

### 🔄 Estados de la pantalla
- Loading / Error / Con datos y filtros

---

## 📱 19 · DestinationMapScreen
**Archivo:** `lib/views/map/destination_map_screen.dart`
**Ruta de navegación:** `/map/destination/:id`
**Propósito:** Mapa individual de un destino. Muestra el marcador del destino, la ubicación del usuario (GPS), una línea de ruta entre ambos y la distancia estimada en km.

### 🧩 Elementos visuales
- AppBar "Ubicación del Destino" con flecha atrás
- Mapa OpenStreetMap con marcador del destino (azul) y del usuario (ícono persona, si hay GPS)
- Línea `Polyline` entre usuario y destino
- Panel inferior con: nombre del destino, ciudad/región, distancia estimada en km

### 🔘 Botones y acciones
| Elemento | Acción que realiza |
|---|---|
| ← Atrás | `TourismMapController.clearSelection()` y regresa |

### ⚙️ Servicios / APIs
- `TourismMapController.loadMarkers()`
- `TourismMapController.selectDestination(marker)`
- `TourismMapController.distanceKm` y `userLocation`

### 🔄 Estados de la pantalla
- Loading / Con destino y usuario / Sin GPS (solo marcador del destino) / Error

---

## 🗺️ RESUMEN FINAL DEL PROYECTO

**Total de vistas:** 19
**Gestión de estado:** Provider (`ChangeNotifier` + `ChangeNotifierProxyProvider`)
**Navegación:** go_router

### Flujo de navegación

```
SplashScreen (/)
  ├─ /main ← sesión activa
  │    └─ MainLayout (tabs)
  │         ├─ [0] HomeScreen → /destination/:id → /feedback/:id
  │         ├─ [1] MapScreen → /destination/:id
  │         ├─ [2] FavoritesScreen → /destination/:id
  │         ├─ [3] RoutesScreen (placeholder)
  │         └─ [4] ProfileScreen
  │                 ├─ /profile/edit
  │                 ├─ /profile/preferences
  │                 └─ /profile/my-reviews
  └─ /welcome ← sin sesión
       ├─ /login → /main
       └─ /register → /onboarding → /main
```

### Tabla resumen

| # | Vista | Propósito | Navega hacia |
|---|---|---|---|
| 01 | SplashScreen | Verifica sesión al inicio | `/main` o `/welcome` |
| 02 | IntroScreen | Presentación de la app (placeholder) | `/welcome` |
| 03 | WelcomeScreen | Bienvenida, puerta de autenticación | `/login`, `/register` |
| 04 | LoginScreen | Login con email y contraseña | `/main`, `/register` |
| 05 | RegisterScreen | Registro en 2 pasos | `/onboarding`, `/login` |
| 06 | OnboardingProfileScreen | Wizard de preferencias viajeras (5 pasos) | `/main` |
| 07 | MainLayout | Shell con 5 tabs de navegación | (gestiona tabs internos) |
| 08 | HomeScreen | Explorar catálogo y "Para ti" con IA | `/destination/:id`, `/search` |
| 09 | FavoritesScreen | Grid de destinos favoritos del usuario | `/destination/:id`, `/main` |
| 10 | RoutesScreen | Mis rutas turísticas (placeholder) | `/main` |
| 11 | ProfileScreen | Datos del usuario, estadísticas y menú | `/profile/edit`, `/profile/preferences`, `/profile/my-reviews`, `/welcome` |
| 12 | EditProfileScreen | Editar nombre y apellidos | Regresa a `/profile` |
| 13 | PreferencesScreen | Editar preferencias + switch IA global | Regresa a `/profile` |
| 14 | MyReviewsScreen | Historial de reseñas enviadas | Regresa a `/profile` |
| 15 | SearchResultsScreen | Búsqueda con filtros y ordenamiento IA | `/destination/:id`, `/profile/preferences` |
| 16 | DestinationDetailScreen | Detalle de destino con 3 tabs adaptativos | `/feedback/:id`, `/map/destination/:id` |
| 17 | FeedbackScreen | Formulario de calificación y reseña | Regresa al destino |
| 18 | MapScreen | Mapa turístico general con filtros por categoría | `/destination/:id` |
| 19 | DestinationMapScreen | Mapa individual con distancia al usuario (GPS) | Regresa al destino |
