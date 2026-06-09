# Documentación Técnica del Frontend Móvil PROXVEL en Flutter

## 1. Título
Documentación técnica del frontend móvil PROXVEL en Flutter

## 2. Introducción
PROXVEL es un aplicativo móvil de recomendación turística personalizada, diseñado para sugerir destinos y rutas adaptadas a las preferencias únicas de cada usuario. El frontend cumple el rol crucial de interactuar con el viajero, capturar sus intereses, presentar de forma atractiva las recomendaciones, y visualizar de manera transparente la justificación (XAI/ABSA) detrás de cada sugerencia de viaje.

## 3. Alcance Actual del Frontend
En su estado actual, el frontend de PROXVEL:
- Funciona localmente sin dependencias externas de red.
- Usa **mock data** (datos simulados) para representar destinos, rutas y recomendaciones.
- Usa **SharedPreferences** a través de `LocalStorageService` para la persistencia.
- Permite un flujo de registro y login local (simulado).
- Permite la captura de preferencias a través del Onboarding.
- Muestra destinos en interfaces premium e interactivas.
- Muestra recomendaciones simuladas con porcentajes de compatibilidad.
- Permite realizar búsquedas por texto y aplicar filtros dinámicos.
- Muestra el detalle del destino, justificando la compatibilidad a través de explicaciones y métricas de aspecto simuladas.
- Permite marcar y desmarcar favoritos localmente.
- Permite explorar e interactuar con rutas simuladas (activas/completas).
- Permite enviar retroalimentación (feedback) simulada localmente.
- Permite consultar y editar el perfil y las preferencias del usuario interactivo.

## 4. Arquitectura Lógica
La aplicación sigue un patrón arquitectónico rígido de separación de responsabilidades:
**View → Controller → Model → Integration**

- **View:** Contiene exclusivamente código UI (Widgets). Muestra la información estructurada, captura la interacción del usuario y delega las acciones a su respectivo controlador. No almacena estado de negocio ni lógica de datos.
- **Controller:** Gestiona el estado y la lógica de negocio de la aplicación. Es el puente entre las Vistas y la Integración. Extiende `ChangeNotifier` para notificar reactivamente a la UI cuando los datos cambian. No contiene Widgets.
- **Model:** Define las estructuras de datos (entidades) mediante clases planas que incluyen soporte nativo para serialización y deserialización (JSON).
- **Integration:** Maneja la obtención y persistencia de datos. Incluye los *Services* (abstracción del origen), fuentes *Mock* (datos simulados), y capas locales (`LocalStorageService`).
- **Core:** No es una capa funcional per se. Es una carpeta transversal de soporte encargada de proveer configuración estática (rutas de navegación, temas de color, widgets genéricos reutilizables y utilidades transversales).

## 5. Estructura de Carpetas
El directorio principal `lib/` está organizado de la siguiente manera:

- `core/`: Contiene estilos, colores base (`AppColors`), componentes UI genéricos (`cards`, `states`), configuración del enrutador (`router.dart`) y herramientas transversales.
- `views/`: Agrupa todas las pantallas organizadas por módulo (auth, home, profile, routes, etc.). Son exclusivamente clases visuales.
- `controllers/`: Aloja los gestores de estado (ej. `HomeController`, `SearchController`) responsables de dictar el comportamiento y coordinar servicios.
- `models/`: Contiene las clases representativas de datos (`UserModel`, `DestinationModel`, `RouteModel`, etc.).
- `integration/`: La capa de conectividad. Contiene `services/` (lógica de abstracción), `mock/` (fuentes de datos en duro) y `local/` (gestión de `SharedPreferences`).
- `app.dart`: Configura los `MultiProvider`, la inyección de dependencias de controladores y los temas principales.
- `main.dart`: El punto de entrada principal que inicializa servicios críticos (como almacenamiento local) y ejecuta la aplicación.

## 6. Flujo General de Datos
1. El usuario interactúa con un elemento en la **View**.
2. La **View** invoca un método en su **Controller** (ej. `context.read<SearchController>().search()`).
3. El **Controller** procesa la petición y consulta al **Service** respectivo.
4. El **Service** obtiene datos de una fuente `MockDataSource` (para simular el backend) o de `LocalStorageService` (para persistencia real simulada).
5. Los datos crudos se estructuran a través de un **Model**.
6. El **Controller** actualiza su estado interno y llama a `notifyListeners()`.
7. La **View**, al estar escuchando (mediante `context.watch`), se re-renderiza con la nueva información.

## 7. Flujo de Autenticación Local
El flujo es orquestado por `AuthController`, consumiendo `LocalStorageService` y manejando instancias de `UserModel`.
- **RegisterScreen / LoginScreen:** Vistas de autenticación.
- El registro persiste los usuarios en una lista local. El login verifica contra esta lista y, de ser válido, establece una "sesión activa" simulada.
- **Advertencia:** Esta autenticación no provee seguridad criptográfica real; es netamente funcional para el prototipo visual del frontend.

## 8. Flujo de Onboarding
- **OnboardingProfileScreen:** Vista de captura secuencial de preferencias del usuario.
- **OnboardingController:** Maneja el flujo paso a paso y empaqueta las opciones seleccionadas.
- Produce un **TravelerProfileModel** que se almacena localmente de manera permanente para nutrir el perfil del viajero.

## 9. Flujo de Home
- **HomeScreen:** Utiliza un `NestedScrollView` con *Sticky Tabs* ("Explorar" y "Para Ti"). Muestra contenido dinámico renderizado.
- El saludo inicial se oculta sutilmente con scroll.
- **HomeController / DestinationService / MockDestinationDataSource:** Carga destinos aleatorios (simulando "Cerca de ti") y los más populares ("Lugares turísticos del momento").
- Incluye un selector dinámico de ciudades (BottomSheet) que actualiza las listas localmente y un buscador interactivo.
- Lee el historial directo de `LocalStorageService` para renderizar *Búsquedas Recientes*.

## 10. Flujo de Búsqueda
- **SearchResultsScreen:** Interfaz para buscar e ingresar filtros multicriterio (categoría, clima, ciudad, presupuesto, compatibilidad).
- **SearchController:** Aplica filtrado paramétrico en memoria sobre los datos mock, ordenando heurísticamente los resultados por "compatibilidad" simulada (de mayor a menor). Navega directamente hacia el `DestinationDetail`.

## 11. Flujo de Detalle y Explicación
- **DestinationDetailScreen:** Visualiza la información completa del destino.
- Utiliza **MockAspectDataSource** y **DestinationController** para suministrar la calificación global.
- Exhibe insignias (`CompatibilityBadge`), gráficos en barra (`AspectScoreBar`) y tarjetas explicativas texturizadas (`ExplanationCard`).
- **Aclaración crucial:** La funcionalidad ABSA (Análisis de Sentimientos Basado en Aspectos), XAI (Inteligencia Artificial Explicable) y el cálculo matemático de compatibilidad son puramente **mock**. En el futuro, el backend inteligente ejecutará y calculará dinámicamente estos factores.

## 12. Flujo de Feedback
- **FeedbackScreen:** Interfaz modal para la recolección de calificaciones y comentarios sobre los destinos.
- Administrado por **FeedbackController**, **FeedbackService** y la entidad **FeedbackModel**, delegando el guardado del formulario en memoria local (`LocalStorageService`).

## 13. Flujo de Favoritos
- **FavoritesScreen:** Renderiza la lista personal del usuario.
- Se comunica en tiempo real con **FavoritesController**, añadiendo o removiendo IDs de destinos hacia el `LocalStorageService` y recargando instantáneamente la vista.

## 14. Flujo de Rutas
- **RoutesScreen:** Pantalla principal de navegación vial organizada por *Todas*, *Activas*, *Completas*.
- Utiliza **RoutesController**, **RouteService** y **MockRouteDataSource**.
- Manipula **RouteModel** empleando la bandera booleana `isCompleted`, cuyo estado actual perdura en `LocalStorageService`.

## 15. Flujo de Perfil
- **ProfileScreen:** Hub visual de estadísticas y opciones de configuración.
- Emplea **ProfileController** en comunión con **TravelerProfileModel**.
- Facilita la edición de "Mis preferencias" reactivando el flujo `/onboarding` en modo edición y permite el cierre de sesión ("Logout") expulsando al usuario hasta `/welcome`.

## 16. Mock Data y Backend Futuro
- **Qué existe:** Archivos como `MockDestinationDataSource`, `MockAspectDataSource` y `MockRouteDataSource`.
- **Por qué se usa:** Para validar interacciones, UI/UX, animaciones y fluidez arquitectónica sin depender de una base de datos ni motor predictivo real todavía no desarrollado.
- **Sustitución Futura:** En el futuro, los *Services* (ej. `DestinationService`) cambiarán su fuente de retorno interna, desechando las referencias al mock para pasar a usar un `ApiClient` ejecutando peticiones HTTP (GET, POST).
- **Inmutabilidad:** Las vistas (`Views`) y controladores (`Controllers`) permanecerán **completamente intactos**; su funcionamiento está ya desacoplado del origen real de los datos.

## 17. Preparación para Backend Futuro
Para conectar a un backend real, el flujo previsto será el siguiente:
1. Instanciar y configurar el **ApiClient** maestro (Dio / HTTP) dentro de `integration/api`.
2. Actualizar los *Services* en `integration/services` para solicitar datos al ApiClient en lugar del mock.
3. Posibles Endpoints futuros recomendados:
   - `POST /api/auth/login` (Reemplazo autenticación local)
   - `POST /api/auth/register` (Reemplazo registro local)
   - `GET /api/profile` (Sincronización de preferencias del viajero)
   - `GET /api/destinations` (Carga del inventario de destinos)
   - `POST /api/recommendations` (Motor IA: devuelve la lista re-rankeada según perfil)
   - `GET /api/search` (Filtros en el servidor)
   - `POST /api/feedback` (Recolección real de reviews para retroalimentar el modelo IA).

## 18. Relación con la Tesis
Este desarrollo frontend permite sustentar en la tesis académica:
- El diseño metodológico para la **captura no intrusiva de preferencias**.
- La eficacia visual de presentación de **recomendaciones ordenadas (Ranking)**.
- El valor percibido de la **explicabilidad (XAI)** a través de los componentes de *aspect-scores*.
- La factibilidad de conectar a futuro un motor backend impulsado por **IA/ABSA** sin fracturar la experiencia de usuario.

## 19. Limitaciones Actuales
- Autenticación local insegura (exclusivamente demostrativa).
- Todos los cálculos estadísticos provienen de generadores aleatorios estáticos.
- Ausencia de Backend y Base de Datos persistente en la nube.
- Inexistencia de rastreo GPS (las métricas "cerca de ti" son simuladas).
- La IA predictiva, clasificación ABSA y ranking cognitivo (XAI) no operan en el motor nativo de Flutter.

## 20. Buenas Prácticas Aplicadas
- **Separación de responsabilidades** (Solid/Clean Architecture enfocado en MVC).
- Datos Mock estricta y rígidamente aislados fuera de las capas de negocio/UI.
- Inyección de dependencias escalables para Controllers y Services.
- Estandarización de Modelos bajo patrones de tipado JSON.
- Reutilización inteligente de Widgets y centralización gráfica.
- Control maestro de navegación apoyado en utilería robusta (`go_router`).

## 21. Estado Actual del Proyecto
- **Análisis de código estático:** `dart analyze` reporta *No issues found!*.
- **Cobertura de Pruebas (Smoke):** `flutter test` aprueba sin errores base.
- **Compilación Operativa:** `flutter build apk --debug` finaliza con código 0 y emite instalador Android.
- **Consideraciones técnicas:** Existe un warning reportado respecto al uso de *Kotlin Gradle Plugin (KGP)* de la librería `shared_preferences_android`. Este factor no compromete la estabilidad, pero requerirá actualización de paquetes en próximos semestres según libere Flutter sus parches oficiales.

## 22. Recomendaciones Futuras
- **Conectar un backend real** que centralice la identidad y autenticación.
- **Integrar de manera unificada el modelo ABSA y Re-Ranking Cognitivo** al momento de buscar y filtrar recomendaciones.
- Generar endpoints específicos para servir métricas XAI en la tarjeta de Explicación de Detalle.
- Considerar la implementación de **"Arquitectura de Creación y Generación Dinámica de Rutas"** solo si el alcance funcional y de plazos de la tesis lo aprueba como necesario.
