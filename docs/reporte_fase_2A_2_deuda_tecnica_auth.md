# Fase 2A.2: Fix de Sincronización Temporal de Usuario y Feedback

Este documento registra la solución aplicada para resolver el error `404: Usuario no existe` al enviar reseñas desde la aplicación, y declara formalmente la **deuda técnica** asumida durante esta etapa de MVP.

## 1. El Problema Detectado
Durante las pruebas desde Android Studio, la pantalla `FeedbackScreen` lograba ensamblar el payload correcto, pero el backend de FastAPI lo rechazaba con una excepción 404.
El problema radicaba en que el `user_id` enviado provenía de una sesión simulada en `LocalStorageService`. Al no existir un flujo de creación o sincronización real de usuarios hacia PostgreSQL, la base de datos desconocía el ID generado localmente (ej. `user_1234`), rechazando la inserción por integridad referencial.

## 2. El Parche Temporal (MVP)
Para permitir que la app sea validable y funcional desde el frontend sin construir de inmediato un módulo de autenticación complejo (que no corresponde a esta fase):
- Se interceptó la creación del modelo de reseña en `FeedbackScreen`.
- Si se detecta que el ID local no tiene un formato válido conocido por el backend (el prefijo `U000`), el código fuerza y sobrescribe temporalmente el identificador a `U00001` (el primer Usuario Demo pre-inyectado en PostgreSQL).

Adicionalmente, se mejoró la experiencia de usuario (UX) implementando un `SnackBar` de error dinámico. Ahora la UI comunica explícitamente cuando una reseña no se puede enviar por falta de sincronización o fallo general del servidor, en lugar de fallar silenciosamente en la consola.

## 3. Declaración de Deuda Técnica (IMPORTANTE)
Este parche **no es autenticación real**. Queda registrada la siguiente deuda técnica para futuras iteraciones:
1.  **Registro y Login Real:** El Frontend debe abandonar el `LocalStorageService` como fuente de verdad para la creación de usuarios, y en su lugar consumir los futuros endpoints de registro y login (`/api/v1/users/register`, `/api/v1/auth/login`).
2.  **Manejo de Sesión (JWT):** Las peticiones como el envío de feedback deberán ir firmadas con un JWT válido, y el `user_id` deberá extraerse del token en el servidor, no depender de lo que envíe el cliente en el cuerpo de la petición.
3.  **Remoción del Fallback `U00001`:** Una vez integrado el login real, este puente temporal (`if (!userId.startsWith('U000')) { userId = 'U00001'; }`) debe ser eliminado del código de producción.

Esta fase queda cerrada a la espera de validación manual.
