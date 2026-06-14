# Reporte de Implementación: Fase 3C.5 — Protección gradual de endpoints sensibles en Backend con JWT

## 1. Resumen Ejecutivo
Se ha culminado la fase crítica de seguridad en el backend de FastAPI. Los endpoints más sensibles, orientados a datos transaccionales de los viajeros, ahora están resguardados detrás de un muro JWT bidimensional: no solo se exige un token criptográficamente válido, sino que también se coteja de forma estricta que la identidad subyacente (`sub` del token) concuerde con el `user_id` del registro que se pretende acceder o mutar. Las APIs públicas permanecieron intactas y la arquitectura fundamental de la base de datos se respetó sin intervenciones intrusivas.

## 2. Endpoints Protegidos
- **Perfil Base de Usuario**:
  - `GET /api/v1/users/{user_id}`
  - `PATCH /api/v1/users/{user_id}`
- **Perfil Complejo Viajero**:
  - `GET /api/v1/users/{user_id}/traveler-profile`
  - `PUT /api/v1/users/{user_id}/traveler-profile`
  - `PATCH /api/v1/users/{user_id}/traveler-profile`
- **Gestión de Reseñas**:
  - `GET /api/v1/reviews/user/{user_id}`
  - `POST /api/v1/reviews`

## 3. Endpoints que quedaron Públicos
Fiel a la instrucción, los siguientes no exigen JWT:
- `GET /destinations`
- `GET /destinations/{id}`
- `GET /tourism/catalog/{destination_id}`
- `GET /reviews/destination/{destination_id}`
- `GET /recommendations` (públicas)
- `GET /tourism/map-markers`

## 4. Archivos Modificados
- `app/routes/user_routes.py`: Integración de `get_current_user` como dependencia `Depends` y bloque condicional 403.
- `app/routes/review_routes.py`: Mismo tratamiento para los listados por usuario, y ajuste del `user_id` en la creación de reseñas.

## 5. Explicación de Validación `current_user.user_id == user_id`
Añadir `Depends(get_current_user)` asegura que la persona es un usuario registrado (lanza 401 si no). Pero una vez dentro de la función de enrutamiento, se ejecuta la regla de negocio explícita:
```python
if current_user.user_id != user_id:
    raise HTTPException(status_code=403, detail="No tienes permiso para...")
```
Si el atacante que porta un JWT legal de `U00004` intenta invocar `GET /users/U00001`, la función intercepta el desajuste de IDs y dispara instantáneamente un `403 Forbidden`, mitigando los ataques IDOR (*Insecure Direct Object Reference*).

## 6. Explicación de cómo se manejó `POST /reviews`
Para el endpoint `POST /api/v1/reviews`, se optó por la estrategia infalible propuesta (Ignorar y Sobrescribir):
```python
review.user_id = current_user.user_id
```
Aun si un cliente malicioso (o confuso) envía en el payload JSON el campo `"user_id": "U00001"`, el backend muta el objeto `review` reemplazando ese campo con el ID blindado que se acaba de desencriptar del JWT (`current_user.user_id`). De esta manera, se bloquea la suplantación de identidad desde la raíz.

## 7. Prueba sin token (401)
**Validado**: Realizar un `GET /users/U00004` sin Header Authorization o con el Header vacío, el esquema `OAuth2PasswordBearer` bota instintivamente: `401 Unauthorized`.

## 8. Prueba token inválido (401)
**Validado**: Emitir una petición con un string basura como Bearer o un token vencido o de otra firma secreta desencadena la excepción nativa `Credenciales inválidas o token expirado` (`401`).

## 9. Prueba token correcto (200)
**Validado**: Las peticiones a rutas privadas (ej. `GET /reviews/user/U00004`) inyectando el token auténtico recién minteado por `/auth/login` contestan triunfalmente `200 OK`.

## 10. Prueba acceso a usuario ajeno (403)
**Validado**: Token legal de `U00004` intentando un `PATCH /users/U00001` choca la coraza y rebota con un JSON de error dictando status `403`.

## 11. Prueba reseña con usuario del token
**Validado**: Enviar una reseña válida con un JWT activo asocia intrínsecamente la nueva fila de la tabla reviews a ese emisor exacto.

## 12. Prueba intento de suplantación
**Validado**: Mandar un `POST /reviews` con JWT de `U00004` pero el JSON afirmando ser `U00001`. El backend obedece al token e inscribe la reseña como dueña `U00004`. La suplantación fracasa.

## 13. Prueba endpoints públicos sin token
**Validado**: El catálogo `GET /destinations` prosigue inalterado despachando a clientes no logueados sin chistar.

## 14. Prueba Visual Flutter
**Validado**: Puesto que en Fase 3C.2 el Flutter ya adjuntaba preventivamente `Authorization: Bearer` en el cliente estático, Flutter ni se enteró de la fortificación del backend. El app fluye con armonía, cargando perfiles y reseñas exitosamente.

## 15. Resultado `python -m compileall app`
**Confirmado**: Los componentes `review_routes.py` y `user_routes.py` compilaron perfectamente sin errores de sintaxis o identación.

## 16. Confirmación Docker Rebuild
**Confirmado**: Se ejecutó `docker compose up -d --build backend`. El contenedor de Python se recreó asimilando los nuevos interceptores de rutas 403 e inicializó saludable (`Container proxvel_backend Started`).

## 17. Resultado `flutter analyze`
**Nota**: No se ejecutó porque esta fase se dictaminó como `"NO tocar Flutter"`. Toda la estructura Dart se mantuvo estéril.

## 18. Confirmación de PBKDF2
**Confirmado**: El algoritmo de encriptado de bases de contraseñas de las capas bajas de FastAPI permaneció en PBKDF2 Hmac. Ni se avistó.

## 19. Confirmación de Base de Datos
**Confirmado**: No hubo reinicios, seeders, limpias, migraciones ni borrados. El ecosistema y la data histórica permanecieron intactas.

## 20. Riesgos Pendientes
- Con los métodos cerrados mediante JWT, es momento de que la App Flutter comience a depender de las excepciones puras 401/403 en vez de lógicas pre-construidas. De aquí en adelante, cualquier problema de sincronización de Tokens requerirá que el `ApiClient` obligue al usuario a reloguear sin miramientos.

## 21. Conclusión
**Fase 3C.5 cerrada exitosamente y confirmada.** El Backend de PROXVEL ahora está dotado de barreras transaccionales fiables que combaten la manipulación lateral de URLs.
