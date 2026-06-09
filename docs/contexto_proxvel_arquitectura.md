# Contexto de Arquitectura y Estado Actual — PROXVEL

**Este documento sirve como "Brain Dump" (Volcado de memoria) para mantener la continuidad en una nueva sesión de desarrollo de Inteligencia Artificial.**

## 1. Estado Actual del Proyecto
Se ha finalizado con éxito un rediseño UI/UX "Premium" (Dark Navy + Amber Accent) y la implementación de la lógica local estructurada desde la Fase 3A hasta la 3E. 
La aplicación actual compila perfectamente: `flutter pub get` y `dart analyze` reportan **0 errores y 0 warnings**.

## 2. Fases Implementadas (Lo que ya funciona)
- **FASE 3A (Home):** `ProxvelBottomNavigation` con **exactamente 4 tabs** fijos (Home, Favoritos, Rutas, Perfil). Home tiene scroll horizontal para "Explorar" y "Para Ti", y búsqueda reciente.
- **FASE 3B (Tabs):** Pantallas de Favoritos (Grid), Rutas (Lista) y Perfil completamente rediseñadas con tarjetas premium.
- **FASE 3C (Detail & Feedback):** `DestinationDetailScreen` usa tarjetas para simular modelos de Inteligencia Artificial (ABSA para aspectos turísticos y XAI para explicación de recomendaciones) usando **datos mockeados**. `FeedbackScreen` está funcional y guarda los datos localmente.
- **FASE 3D (Auth & Onboarding):** Flujo de Registro, Login y Onboarding del viajero (captura de preferencias). Usa validación simulada local guardando todo en `LocalStorageService`. Home lee el nombre completo del usuario activo.
- **FASE 3E (Search & Filters):** `SearchResultsScreen` recibe el texto desde Home. Permite buscar por texto y abrir un `SearchFilterSheet` (bottom sheet) para filtrar por ciudad, categoría, clima, presupuesto y compatibilidad. Ordena la lista automáticamente de mayor a menor compatibilidad.

## 3. Arquitectura (REGLA INQUEBRANTABLE)
El proyecto utiliza un patrón MVC estricto: **View → Controller → Model → Integration**.
* **Views** (`lib/views/`): Solo renderizan UI y capturan eventos del usuario. Tienen estrictamente prohibido contener lógica de negocio o datos quemados (mock data).
* **Controllers** (`lib/controllers/`): Manejan el estado (ChangeNotifier). Se comunican con los Services. Están inyectados en la raíz mediante Provider en `lib/app.dart`.
* **Models** (`lib/models/`): Clases de datos puras (ej. `DestinationModel`, `UserModel`).
* **Integration** (`lib/integration/`): Contiene los `Services` (intermediarios) y las subcarpetas `mock/` (donde reside TODA la data simulada estructurada) y `local/` (`LocalStorageService` con SharedPreferences).

## 4. Reglas Estrictas para el Próximo Desarrollo
1. **No romper el MVC:** Si necesitas agregar data, se agrega en `integration/mock/`, se expone mediante un Service, se carga en un Controller y la View lo lee por Provider.
2. **No backend real, no IA real:** El proyecto es un prototipo demostrativo frontend. Todas las referencias a algoritmos, ABSA, XAI y logins son simulaciones de almacenamiento local o memoria estructurada.
3. **Mantén el Sistema de Diseño:** Usa SIEMPRE los colores de `AppColors` y la tipografía de `AppTextStyles` para conservar la coherencia "Premium".
4. **Bottom Navigation Fijo:** No agregues más de 4 tabs (Home, Favoritos, Rutas, Perfil).

## 5. Próximo Paso Definido por el Usuario
El core lógico ya está listo. El siguiente objetivo es **implementar y refinar nuevas vistas a nivel de diseño**, siguiendo las reglas anteriores al pie de la letra.
