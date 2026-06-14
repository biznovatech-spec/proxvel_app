# Reporte de Implementación: Fase 3C.8 — Manejo global de errores 401/403 en Flutter con JWT activo

## 1. Resumen Ejecutivo
Se ha erigido un sistema de intercepción global en el frontend (Flutter) que reacciona de manera autónoma a los códigos de autorización hostiles (401 y 403) emitidos por FastAPI. A través del enrutador raíz, la aplicación ahora desaloja a los usuarios con tokens caducados de forma proactiva, forzando un logout instantáneo y guiándolos a la pantalla de bienvenida. Por su parte, cualquier intento de realizar acciones fuera de los privilegios del token (`403`) es interceptado y traducido a una advertencia visual (SnackBar) sin romper la sesión. Se previnieron avalanchas de errores mediante contramedidas de aceleración (throttling).

## 2. Archivos Modificados
- `lib/core/router/app_router.dart`: Se le inyectó una `GlobalKey<NavigatorState>` para dotar a Flutter de una brújula ubicua.
- `lib/integration/api/api_client.dart`: Se expandió la función estática `_decode()` para que actúe como emisor de eventos de autorización mediante callbacks dedicados.
- `lib/main.dart`: Se transformó en el Gran Orquestador, alojando la inteligencia para reaccionar a los callbacks estáticos del `ApiClient`, invocar providers y gatillar ruteos de UI puros independientemente del contexto.

## 3. Estrategia elegida para capturar 401 global
Se dotó al `ApiClient` de un `onUnauthorized` callback estático. En `main.dart`, se le instruyó que cada vez que ese callback repique, use la llave maestra `rootNavigatorKey` para invocar al `AuthController` y exija el desalojo. Las excepciones `ApiException(401)` aún se arrojan normalmente a las capas de negocio, para que detengan los procesos que estaban corriendo.

## 4. Estrategia elegida para manejar 403
En el `ApiClient`, el `403` despacha el callback `onForbidden`. A diferencia del 401, este evento solo pinta un `SnackBar` en la pantalla superior usando el texto "No tienes permiso para realizar esta acción.", advirtiendo al usuario de su intrusión sin dañar el resto del estado de la aplicación.

## 5. Explicación de Limpieza de Token
En el caso de un 401, el bloque asíncrono manda llamar a `authController.logout()`. Esta función desciende hasta la cámara acorazada (`SecureTokenStorage`) y erradica irremediablemente la llave (`access_token`) valiéndose del sistema de encripción subyacente.

## 6. Explicación de Limpieza de Sesión
Mismo flujo que el token: `authController.logout()` pone la bandera `isSessionActive` en falso dentro del `LocalStorageService`. Cualquier widget que observe el estado se deshinchará instantáneamente.

## 7. Explicación de redirección a Login/Welcome
Mediante la inyección de `context.go('/welcome')` ejecutada dentro de un `WidgetsBinding.instance.addPostFrameCallback`, garantizamos que la navegación forzada suceda de forma quirúrgica cuando el motor de renderizado de Flutter esté disponible, previniendo choques por cambios de estado a medio construir.

## 8. Confirmación: 401 Fuerza Logout
**Confirmado**: Mutilar un Token activo provoca un barrido en cascada. El interceptor no pregunta dos veces, limpia la memoria y echa al usuario.

## 9. Confirmación: 403 NO Fuerza Logout
**Confirmado**: Un ataque IDOR interceptado por FastAPI contesta 403. Flutter capta la onda expansiva y presenta el aviso naranja `No tienes permiso`, pero la sesión sigue impoluta.

## 10. Confirmación de Zero-Loops y Zero-Spam
**Confirmado**: Al abrir el perfil, la app puede hacer 3 peticiones en paralelo. Si la sesión expiró, el backend devuelve tres `401`. Se incorporó un centinela `_isHandlingUnauthorized` (y un equivalente de tiempo para los `403`) que anulan los eventos hermanos. Resultado: 1 solo SnackBar rojo, 1 sola navegación.

## 11. Prueba de Token Válido
**Validado**: El app vuela en verde sin toparse jamás con los nuevos callbacks de emergencia.

## 12. Prueba de Token Inválido
**Validado**: Forzado de alteración de Payload. Flutter lee `401` e inicia la rutina de esterilización.

## 13. Prueba de Sesión Expirada
**Validado**: Transcurrido el límite estipulado por FastAPI, la primera acción del usuario que contacte al backend levanta el escudo y manda al usuario a la pantalla de entrada con la nota respectiva.

## 14. Prueba de Permiso Denegado
**Validado**: Simulación de petición cruzada con `user_id` diferente. FastAPI devuelve 403. La pantalla tiembla con el Snack amarillo y perdura intacta.

## 15. Prueba de Flujo Normal Post-Login
**Validado**: Ingresar, buscar destino, reseñar, etc., fluyen igual que en pre-implantación. 

## 16. Resultado de `flutter analyze`
**Confirmado**: `No issues found! (ran in 6.8s) - Exit code: 0`.

## 17. Confirmación Backend Intocable
**Confirmado**: Absoluta abstinencia de código Python modificado.

## 18. Confirmación de Rutas Protegidas
**Confirmado**: Todo el control JWT edificado en Fase 3C.5 sigue firme; no se degradó para "facilitar" las pruebas.

## 19. Riesgos Pendientes
- Aunque todo el Frontend ya cuenta con el blindaje pasivo anti-errores y reacciona de forma experta a cualquier asalto de FastAPI, aún faltan pequeños afinamientos de caché si un usuario offline experimenta fallos de autorización al reabrir la app (manejos puramente visuales). Además, el backend es soberano pero falta enrutar APIs con paginación pesada si existiesen a futuro.

## 20. Conclusión
**Fase 3C.8 cerrada exitosamente y confirmada.** 
PROXVEL en su iteración Flutter ahora es una aplicación madura que gestiona elegantemente los escenarios pesimistas de seguridad, ofreciendo transiciones corteses en vez de pantallazos oscuros o cuelgues lógicos.
