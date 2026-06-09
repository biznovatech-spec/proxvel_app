# Contexto del Proyecto PROXVEL (Para Migración a Flutter MVC)

Este documento contiene el contexto y estado actual del proyecto **PROXVEL**, con el objetivo de servir como base para diseñar la arquitectura del frontend en **Flutter** utilizando el patrón **MVC** (Modelo-Vista-Controlador).

## 1. Estado Actual del Proyecto
- **Tecnología Actual:** Android Nativo (Kotlin + Jetpack Compose).
- **Objetivo de Migración:** Reescribir el frontend en **Flutter** implementando una arquitectura **MVC**.
- **Backend:** **No hay conexión a backend en este momento.** Todo el proyecto es exclusivamente frontend. Los datos se manejan mediante fuentes de datos locales simuladas (Mock Data, ej. `MockRecommendationDataSource`).
- **Próximos Pasos:** La conexión con el backend (API REST) se implementará inmediatamente después de finalizar la estructura del frontend en Flutter.

## 2. Estructura de Carpetas Actual (Kotlin)
La aplicación actualmente sigue una estructura basada en "features" y "Clean Architecture", que deberá ser adaptada a **MVC** en Flutter.

Las carpetas principales son:
- `core/`: Utilidades comunes, navegación (`AppNavigation.kt`), manejo de sesión.
- `data/`: Modelos de datos, repositorios, y fuentes de datos locales (MockData, Preferencias locales de sesión).
- `domain/`: Lógica de negocio (casos de uso, interfaces).
- `feature/`: Contiene las pantallas (UI) y ViewModels, divididas por módulo:
  - `auth/` (Login, Registro, Welcome)
  - `onboarding/` (Animación inicial, Preferencias de usuario)
  - `main/` (Contenedor principal con Bottom Navigation Bar)
  - `home/` (Explorar)
  - `foryou/` (Para ti)
  - `favorites/` (Favoritos)
  - `profile/` (Perfil de usuario, Logout)
  - `destination/` (Detalle del destino turístico)
  - `search/` (Resultados de búsqueda y filtros)
- `ui/`: Temas globales, colores, tipografía.

## 3. Rutas y Flujos de Navegación
El flujo actual de la aplicación contempla las siguientes rutas principales:

1. **Flujo de Introducción:**
   - `intro`: Pantalla de animación inicial.

2. **Flujo de Autenticación (`auth_graph`):**
   - `auth`: Pantalla de bienvenida (Welcome).
   - `login`: Inicio de sesión.
   - `register`: Creación de cuenta.

3. **Flujo de Onboarding (`onboarding_graph`):**
   - `onboarding_preferences`: Formulario para capturar preferencias del usuario antes de entrar a la app principal.

4. **Flujo Principal (`main`):**
   - Actúa como el *Shell* de la app, conteniendo el Bottom Navigation Bar.
   - Pestañas internas: Inicio (Home/Explorar), Para Ti (Recomendaciones), Favoritos, Perfil.

5. **Flujos de Detalle y Búsqueda:**
   - `destination_detail/{id}`: Pantalla de detalles de un destino turístico específico (contiene pestañas de "Por qué te encantará" e "Información", y mapas).
   - `search_results`: Pantalla de resultados de búsqueda dinámica. Soporta parámetros por URL: `query`, `city`, `budget`, `category`. Incluye un Bottom Sheet para filtros.

## 4. Requerimientos para la Nueva Arquitectura en Flutter (MVC)
La otra IA deberá tomar esta información y generar una propuesta de directorios y arquitectura en **Flutter** que cumpla con:
1. **Patrón MVC:** Separar claramente los Modelos, las Vistas (Widgets/Screens) y los Controladores.
2. **Preparado para Backend:** La capa de Modelos/Controladores debe estar lista para reemplazar la data Mock actual por llamadas HTTP reales (ej. paquete `http` o `dio`) sin afectar las Vistas.
3. **Manejo de Rutas:** Proponer un sistema de enrutamiento en Flutter (ej. `go_router` o `Navigator 2.0`) que soporte los flujos mencionados (auth, onboarding, main shell, argumentos dinámicos como IDs y filtros de búsqueda).
4. **Diseño Visual:** Mantener un estándar visual "Premium" (interfaces modernas, animaciones suaves, uso de componentes dinámicos) que ya venía trabajándose en la versión nativa.
