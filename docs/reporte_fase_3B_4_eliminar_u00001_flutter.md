# Reporte de Fase: 3B.4 — Eliminar uso hardcodeado de U00001 en Flutter

## 1. Resumen Ejecutivo
Se completó la **Fase 3B.4**. Se procedió a erradicar de forma segura el uso del fallback silente `U00001` como comodín principal para las peticiones críticas de Feedback y Mis Reseñas en Flutter. A partir de ahora, la aplicación confía estrictamente en la identidad del usuario extraído de la sesión actual (`AuthController.currentUser`). Si la sesión es inválida, carece de permisos o es una simulación local, las peticiones hacia el backend se bloquean proactivamente mostrando un aviso de error visual al usuario pidiéndole registrarse, protegiendo así la integridad analítica de la base de datos de PostgreSQL sin tocar el backend.

## 2. Archivos Modificados
- `lib/views/feedback/feedback_screen.dart`
- `lib/controllers/my_reviews_controller.dart`
- `lib/integration/api/api_config.dart`

## 3. Sustituciones y Modificaciones de Flujo (`U00001`)
- **En `feedback_screen.dart`**:
  - *Antes:* Si no había usuario logueado o era local, se inyectaba forzosamente `userId = 'U00001'`.
  - *Ahora:* El envío del rating a `POST /reviews` verifica al `currentUser`. Si el usuario es nulo o su ID no empieza con `"U000"`, se muestra un `SnackBar` rojo indicando *"No se encontró un usuario activo. Regístrate o inicia sesión para continuar."* y se bloquea la solicitud HTTP.
- **En `my_reviews_controller.dart`**:
  - *Antes:* Al cargar la vista de Mis Reseñas, si la sesión local carecía de un perfil en el backend, forzaba el fetch con `U00001`.
  - *Ahora:* Se detiene el flujo temprano. La lista de reseñas queda vacía y se pinta el error al usuario instándolo a crear una cuenta.
- **En `api_config.dart`**:
  - Se agregó documentación explícita en `demoUserId = 'U00001'` aclarando que **solo es un fallback para ranking contextual** y ya no tiene utilidad de suplantación en el flujo transaccional.

## 4. Validación de Contratos
- **Feedback:** Cuando hay un usuario real (ej. `U00012`), el body viaja impecable:
  ```json
  {
    "user_id": "U00012",
    "destination_id": "...",
    "rating_general": 5,
    "review_text": "...",
    "aspect_ratings": []
  }
  ```
- **Mis Reseñas:** Cuando hay un usuario real, consulta eficientemente:
  `GET /api/v1/reviews/user/U00012`
- **U00001 Backend:** La base de datos no sufrió manipulaciones. El usuario 1 sigue existiendo sin ser vulnerado.
- **Backend intacto:** Todos los cambios sucedieron en el cliente.
- **Autenticación (JWT):** No se integró. Se basó enteramente en el mock lógico `startsWith('U000')` derivado del registro directo (`auth_controller`).

## 5. Pruebas y Resultados
- **Resultado `flutter analyze`**: **0 issues found**.
- **Prueba Manual Reseñas**: Accediendo con sesión real, el payload se armó correctamente con el user_id de sesión.
- **Prueba Manual Fallback**: Tratando de ingresar un feedback habiendo borrado datos locales (o sin registrarse) arrojó exitosamente el SnackBar de error protector en pantalla impidiendo la inyección silenciosa en PostgreSQL.
- **Respuesta Postman**: `GET /api/v1/reviews/user/{user_id_real}` muestra las reseñas atribuidas al nuevo usuario (y de no haber ninguna, un arreglo vacío limpio sin mezclar el historial de la fase 2).

## 6. Deuda Técnica Restante
Con la eliminación exitosa de este riesgo, el MVP continúa aproximándose a Producción. Faltan por solventar las siguientes tareas:
- Implementar login/JWT real.
- Conectar favoritos al backend.
- Conectar rutas/mapa.
- Conectar Cloudinary/avatar real.
