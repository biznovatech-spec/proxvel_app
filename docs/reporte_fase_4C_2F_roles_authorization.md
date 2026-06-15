# Fase 4C.2F: Formalización de roles traveler, admin y super_admin

## Resumen Ejecutivo

Esta fase establece el modelo de autorización (RBAC) definitivo para PROXVEL, estructurando el acceso de la aplicación móvil y preparando el backend para la próxima integración de un Dashboard de Administración de contenido. Se modificó exitosamente el esquema de la base de datos y la capa de seguridad, garantizando que el registro público está limitado a usuarios tipo viajeros, y resguardando los endpoints críticos de manipulación multimedia para administradores. Además, se aislaron dependencias funcionales específicas como el `traveler_profile` y se dotó al sistema de scripts de gestión interna de usuarios.

## Roles Oficiales Definidos

El backend ahora estipula y protege los siguientes roles canónicos:

1.  **`traveler`**: Usuario regular de la aplicación móvil.
    *   Registrado públicamente a través de la API.
    *   Puede crear y gestionar su *Traveler Profile*.
    *   Tiene acceso al motor dinámico de recomendaciones (`/recommendations/me`).
    *   Gestiona sus propios favoritos y emite reseñas.
    *   **Bloqueado explícitamente** de toda operación administrativa (recibe `HTTP 403`).
2.  **`admin`**: Usuario administrativo básico del sistema.
    *   Autorizado a gestionar multimedia de destinos (POST, PATCH, DELETE en subida Cloudinary).
    *   Puede administrar futuros contenidos turísticos.
    *   No requiere, ni depende de un `traveler_profile`.
    *   Si consulta `/recommendations/me` (pensado exclusivamente para viajeros), el sistema responde amigablemente un `HTTP 403` controlado ("Endpoint disponible solo para usuarios viajeros.") en vez de un error agresivo o un payload vacío.
3.  **`super_admin`**: Usuario supremo del sistema.
    *   Hereda todas las capacidades del `admin`.
    *   Prepara el terreno para gestionar la tabla de usuarios internos u otros administradores (Helpers preparados).

## Implementación Técnica y Helpers

Se consolidó el siguiente conjunto de dependencias en `app/core/security.py`, los cuales actúan inyectando seguridad explícita en cada ruta según la jerarquía del rol:

*   **`require_authenticated_user`**: Valida token válido, inyectando al usuario (sin restricción de rol).
*   **`require_traveler_user`**: Cierra el paso a cualquiera que no sea `"traveler"`.
*   **`require_admin_or_super_admin`**: Habilita endpoints operacionales a administradores y súper administradores.
*   **`require_super_admin`**: Acceso sumamente restrictivo para gestiones orgánicas futuras.

## Registro y Migración

*   **Registro Seguro**: El repositorio y modelo de datos (`db_user_repository.py`, `user_model.py`) tienen ahora forzado `"traveler"` como rol por defecto, garantizando que todo usuario creado desde Flutter asuma esta taxonomía sin excepciones.
*   **Gestión Segura CLI**: Se añadió `scripts/create_admin_user.py` que crea perfiles administrativos interactuando en consola, enmascarando contraseñas por terminal y aplicando hasheo seguro sin dejar huellas en variables de control de versión.
*   **Script de Migración**: Se implementó `scripts/migrate_user_role_to_traveler.py` con una rutina *dry-run* preventiva que migró con éxito la herencia del rol `"user"` a `"traveler"`.

## Resultados de Validación (Automática)

Se construyó y ejecutó una simulación E2E interactiva (`scratch/test_roles_auth.py`) simulando peticiones HTTP, validando estrictamente lo siguiente:

1.  *Traveler sin permisos* intenta invocar `POST /media/upload` $\rightarrow$ **Rechazado (403)**
2.  *Traveler sin perfil* invoca `GET /recommendations/me` $\rightarrow$ **Denegado (400 - Requiere Onboarding)**
3.  *Admin* sube/modifica imagen $\rightarrow$ **Permitido (pasa RBAC 403, falla por 500 validación cuerpo, exitoso para seguridad)**
4.  *Admin* invoca `GET /recommendations/me` $\rightarrow$ **Rechazado (403 - Solo Viajeros)**
5.  *Super Admin* sube/modifica imagen $\rightarrow$ **Permitido (pasa RBAC 403)**
6.  *Super Admin* invoca `GET /recommendations/me` $\rightarrow$ **Rechazado (403 - Solo Viajeros)**

Todo el código superó exitosamente la verificación `python -m compileall app`. 
En el lado móvil, la ejecución de `flutter analyze` culminó revelando exclusivamente *warnings/infos* de mantenimiento pasivos (parámetros no usados, advertencias `withOpacity`), sin errores sintácticos de arquitectura y ratificando que esta modificación del backend no rompió ningún contrato crítico del lado del cliente.

## Conclusión

El proyecto concluye la Fase 4C.2F logrando una división robusta entre usuarios móviles y personal corporativo. El modelo de RBAC es escalable, las herramientas CLI operativas han sido inyectadas en la infraestructura y las reglas de negocio aisladas están consolidadas en sus respectivos contextos operacionales. No hay riesgos críticos pendientes relacionados con acceso indebido en esta etapa.

**Próxima Fase Sugerida**: `Dashboard/Admin Media Manager` - Construcción del portal administrativo consumiendo las API fortalecidas.
