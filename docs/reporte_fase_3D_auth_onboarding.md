# Reporte FASE 3D — Auth & Onboarding

**Fecha**: 2026-05-31  
**Objetivo**: Refinar funcional y visualmente LoginScreen, RegisterScreen, WelcomeScreen y OnboardingProfileScreen. Conectar el registro y login local simulado, corregir warnings preexistentes, y asegurar que Home y Profile muestren el nombre real del usuario logueado.

---

## Archivos Creados (0)

No se crearon archivos nuevos en esta fase.

---

## Archivos Modificados (9)

| Archivo | Ubicación | Cambios |
|---------|-----------|---------|
| `user_model.dart` | `lib/models/` | Campos nuevos: `lastName`, `password` (local-only, no hashing). Getter `fullName` para display. Valores por defecto para retrocompatibilidad |
| `local_storage_service.dart` | `lib/integration/local/` | Métodos nuevos: `registerUser()`, `getAllRegisteredUsers()`, `findUserByEmail()`. Almacena lista de usuarios registrados en SharedPreferences |
| `auth_controller.dart` | `lib/controllers/` | `register()` guarda usuario + activa sesión. `login()` valida email/password localmente y retorna mensaje de error o null |
| `register_screen.dart` | `lib/views/auth/` | Ahora llama a `AuthController.register()` con nombre, apellido, email y contraseña antes de navegar a onboarding |
| `login_screen.dart` | `lib/views/auth/` | Ahora valida credenciales localmente. Muestra error inline premium si credenciales son incorrectas. Limpia errores al editar campos |
| `welcome_screen.dart` | `lib/views/auth/` | Fix: `withOpacity` → `withValues(alpha:)` |
| `auth_layout_wrapper.dart` | `lib/views/auth/widgets/` | Fix: 5 instancias de `withOpacity` → `withValues(alpha:)`. Fix: `use_null_aware_elements` lint |
| `social_auth_button.dart` | `lib/views/auth/widgets/` | Fix: `withOpacity` → `withValues(alpha:)` |
| `widget_test.dart` | `test/` | Fix: removido `import 'package:flutter/material.dart'` no usado |

### Archivos tocados marginalmente (solo getter)

| Archivo | Cambio |
|---------|--------|
| `home_screen.dart` | `currentUser?.name` → `currentUser?.fullName` |
| `profile_screen.dart` | `user?.name` → `user?.fullName` |

---

## Flujo Register → Onboarding → Home

```
RegisterScreen
├── Paso 1: nombre, apellido, email
├── Paso 2: contraseña, confirmación, términos
└── "Registrarme"
    ↓
    AuthController.register()
    ├── Crea UserModel con id timestamp
    ├── LocalStorageService.registerUser(user) → guarda en lista
    ├── LocalStorageService.saveUser(user) → sesión activa
    └── setSessionActive(true)
    ↓
    context.go('/onboarding')
    ↓
    OnboardingProfileScreen
    ├── Captura preferencias del viajero
    └── OnboardingController.saveProfile() → LocalStorageService
    ↓
    context.go('/main')
    ↓
    MainLayout → HomeScreen
    ├── AuthController.currentUser?.fullName → "Daniel Pérez"
    └── (no más "Viajero" hardcoded)
```

## Flujo Login → Home

```
LoginScreen
├── Email + Contraseña
└── "Iniciar Sesión"
    ↓
    AuthController.login(email, password)
    ├── LocalStorageService.findUserByEmail(email)
    ├── Si no existe → "No se encontró una cuenta con ese correo."
    ├── Si password != → "La contraseña es incorrecta."
    └── Si OK → saveUser + setSessionActive(true) → return null
    ↓
    Si error != null → muestra error inline (fondo rojo, icono)
    Si null → context.go('/main')
    ↓
    MainLayout → HomeScreen
    ├── AuthController.currentUser?.fullName → nombre real
```

---

## Confirmaciones Obligatorias

| Requisito | Estado |
|-----------|--------|
| Usuario guardado localmente al registrarse | ✅ `registerUser()` → SharedPreferences lista `registered_users` |
| Login valida contra usuarios guardados | ✅ `findUserByEmail()` + comparación de password |
| Sesión se activa al login/registro | ✅ `setSessionActive(true)` + `saveUser()` |
| Home muestra el nombre real local | ✅ `currentUser?.fullName` (no hardcoded) |
| Profile muestra usuario y preferencias | ✅ `currentUser?.fullName` + ProfileController |
| Campo password NO usa `passwordHash` | ✅ Usa `password` (local-only, no hashing) |
| **NO** hay backend real | ✅ Todo es local via SharedPreferences |
| **NO** hay IA en Flutter | ✅ No hay ABSA, ranking, re-ranking, XAI real |
| **NO** hay mock data en views/controllers | ✅ Solo en `integration/mock/` y `integration/local/` |
| BottomNavigation mantiene 4 tabs | ✅ No se tocó |
| Warnings `withOpacity` corregidos | ✅ 7 instancias corregidas a `withValues(alpha:)` |
| Warning `widget_test.dart` corregido | ✅ Import no usado removido |

---

## Resultado de flutter pub get

```
Resolving dependencies...
Got dependencies!
```
✅ Sin errores

---

## Resultado de dart analyze

### Archivos FASE 3D (scoped)
```
Analyzing auth, auth_controller.dart, user_model.dart,
local_storage_service.dart, home_screen.dart, profile_screen.dart,
widget_test.dart...
No issues found!
```
✅ **0 errores, 0 warnings, 0 infos** en archivos de FASE 3D

### Proyecto completo
```
Analyzing proxvell_app...
   info - lib/app.dart:32:32 - unnecessary_underscores
   info - lib/app.dart:35:32 - unnecessary_underscores
2 issues found.
```
✅ Reducido de **13 issues** (pre-FASE 3D) a **2 issues** — ambos en `app.dart` (convención de nombres de parámetros en rutas)

---

## Errores Pendientes

| Archivo | Tipo | Descripción |
|---------|------|-------------|
| `app.dart:32` | info | `unnecessary_underscores` — parámetro de ruta usa `__` |
| `app.dart:35` | info | `unnecessary_underscores` — parámetro de ruta usa `__` |

Estos son info-level en GoRouter y no afectan la funcionalidad. Se pueden corregir en cualquier fase futura.

---

## Recomendaciones para FASE 3E

1. **SearchResultsScreen**: Implementar pantalla de resultados de búsqueda con filtros (por ciudad, categoría, presupuesto).
2. **Filtros visuales**: Bottom sheet con chips seleccionables para ciudad, categoría, rango de presupuesto y clima.
3. **Ordenamiento por compatibilidad**: Usar los porcentajes mock de `MockAspectDataSource.getCompatibility()` para ordenar resultados.
4. **Conexión con búsquedas recientes**: Los chips de búsqueda reciente del Home deben navegar a SearchResults pre-filtrados.
5. **Fix app.dart**: Corregir los 2 info warnings restantes en `app.dart` renombrando parámetros de ruta.
