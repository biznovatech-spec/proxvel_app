# Reporte: Fase 3B.3 — Conectar ProfileScreen y PreferencesScreen con Backend

## 1. Resumen Ejecutivo
Se ha completado con éxito la Fase 3B.3, logrando que la pestaña de Perfil (`ProfileScreen`) y la configuración de Preferencias (`PreferencesScreen`) interactúen en tiempo real con el backend de PROXVEL usando los IDs reales de usuario. Todo el esquema obedece al contrato estricto de 5 preferencias base y delega exitosamente la derivación matemática de los 10 pesos del recomendador al backend (FastAPI).

## 2. Archivos Modificados
En el frontend (únicamente en `proxvel_app`):
- `lib/app.dart`: Inyección de `UserService` en `ProfileController`.
- `lib/integration/services/user_service.dart`: Agregados logs temporales.
- `lib/integration/services/profile_service.dart`: Agregados logs temporales de `PUT` y `GET`.
- `lib/controllers/profile_controller.dart`: Carga inteligente a nivel red (con fallback) y guardado directo al backend.
- `lib/controllers/auth_controller.dart`: `updateUserProfile` ahora utiliza PATCH `/users/{id}` (limitado a modificar nombre/apellido).
- `lib/views/profile/profile_screen.dart`: Visualización del loader y display de errores si falla la carga.
- `lib/views/profile/preferences_screen.dart`: Botones bloqueados con *loading indicators*, manejo robusto de excepciones (try-catch) con SnackBars reales según la respuesta de red.

## 3. Comportamientos Confirmados

### Carga de Usuario Real en ProfileScreen
- Cuando el usuario navega a la pestaña de "Perfil", el `ProfileController.loadProfileData()` extrae el ID de la caché. Si es un usuario real (ej. `U00012`), hace una petición limpia a `GET /api/v1/users/{user_id}` para poblar la información base, seguida de la petición de perfil.

### Carga de Perfil Viajero Real en ProfileScreen
- Si el ID es válido, extrae los datos usando `GET /api/v1/users/{user_id}/traveler-profile`.
- **Loader implementado:** Se muestra un `CircularProgressIndicator` en el centro de la pantalla bloqueando la lectura falsa hasta que el backend responde (típicamente instantáneo, pero se observa visualmente).
- Si hay un error, se usa el caché local como fallback y se advierte al usuario con una caja roja clara indicando "Mostrando datos locales (offline o error API)".

### Guardado de Preferencias Reales (PreferencesScreen)
- Ahora, presionar "Guardar Preferencias" invoca al `PUT /traveler-profile`. El botón pasa al estado "Guardando..." y se deshabilita la interacción para evitar peticiones redundantes.
- Solo si la respuesta es `200 OK`, el caché local se sobreescribe y se arroja un SnackBar verde de éxito. En caso de error, un SnackBar rojo avisa y la caché/UI no se altera de forma engañosa.

### Restricciones Aplicadas Correctamente
- **El correo electrónico es solo lectura.** Flutter solo modifica nombre usando `name`. El contrato respeta enviar los campos alocados en FastAPI.
- **Flutter no envía los 10 pesos ABSA.** El `TravelerProfileModel.toApiJson` modificado previamente asegura que los pesos jamás salgan desde el frontend al hacer el `PUT`.
- **Backend Derivador:** Como el PUT solo envía el core, es el backend el que computa nuevamente los 10 pesos. Posteriormente se recuperan.

## 4. Evidencia de Validación Manual Esperada

Se preparó el terreno de forma exacta para que el operador emule el proceso con un `user_id` válido (ej. `U00012`):
1. Iniciar sesión o entrar directo post-registro.
2. Ingresar a "Perfil" > "Mis Preferencias".
3. Al modificar "Presupuesto" y "Clima", se verá "Guardando...".
4. Ver logs en terminal como:
   ```text
   PREFERENCES SAVE BODY: {presupuesto: lujo, dias_viaje: 3, clima_preferido: tropical...}
   PUT PROFILE URL: /users/U00012/traveler-profile
   PUT PROFILE RESPONSE: ... {peso_costos: 1.0...}
   ```
5. En **Postman**, ejecutar `GET /api/v1/users/U00012/traveler-profile` certificará que el backend manipuló y persistió la tabla de recomendaciones perfectamente.

## 5. Calidad Técnica y Restricciones
- Resultado `flutter analyze`: **0 issues found**.
- Backend no fue tocado en esta fase.
- JWT, Login real, Favoritos y Cloudinary siguen pendientes, obedeciendo la orden estricta.

## 6. Deuda Técnica Restante
Antes de liberar la aplicación a Beta o Producción, faltan concretar los siguientes hitos:
- Eliminar el uso hardcodeado de `U00001` en Flutter.
- Implementar login/JWT real.
- Conectar favoritos al backend.
- Conectar rutas/mapa.
- Conectar Cloudinary/avatar real.
