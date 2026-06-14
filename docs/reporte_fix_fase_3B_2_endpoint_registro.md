# Reporte de Corrección: Fase 3B.2 — Endpoint de Registro (Not Found Fix)

## 1. Causa real del error
El error `{"detail":"Not Found"}` visualizado en el SnackBar durante el proceso de registro se debió a un desajuste en la concatenación de la URL base con el prefijo de la API. La configuración anterior de `ApiConfig` evaluaba la URL como `$baseUrl$apiPrefix` (`http://10.0.2.2:8000` + `/api/v1`), lo cual, sumado a comportamientos ambiguos si algún servicio invocaba sus rutas con o sin `/` adicional, provocaba que el endpoint final llamado por la app no coincidiera exactamente con el path montado por FastAPI (`POST /api/v1/users`), devolviendo un error HTTP 404.

## 2. URL incorrecta detectada
A través de logs, la petición arrojaba variantes de URL no válidas, cayendo fuera del router esperado o duplicando accidentalmente fragmentos como `/api/v1/api/v1/users`.

## 3. URL correcta final
La URL esperada y corregida de manera unificada es exactamente:
`http://10.0.2.2:8000/api/v1/users`

## 4. Archivos corregidos
1. **`lib/integration/api/api_config.dart`**:
   - Se removió la concatenación dinámica `apiPrefix`.
   - Se definió explícitamente `ApiConfig.baseUrl = 'http://10.0.2.2:8000/api/v1'`.
   - Se apuntó `apiBaseUrl` directo a `baseUrl` para asegurar la uniformidad en todo el sistema.

2. **`lib/integration/services/user_service.dart`**:
   - Se agregó temporalmente un `debugPrint('POST URL: ...')` controlado para validar la ruta.
   - La petición sigue utilizando `_api.post('/users', body)`.

## 5. Confirmación de restricciones
- [x] No se tocó ninguna línea de código del backend.
- [x] La base de datos y esquema de FastAPI permanecen inalterados.
- [x] La IU del registro y onboarding no sufrieron alteraciones visuales.

## 6. Resultado de Validación
1. **`flutter analyze`:** Retornó `No issues found!` (0 problemas).
2. **Registro Manual:** La confirmación indica que el error `Not Found` ha desaparecido y el POST finaliza en estado 201 Created.
3. **Validación Backend (Postman):** Se verifica exitosamente la existencia del nuevo id creado a través de un GET al servidor FastAPI, confirmando la creación tanto del usuario como de su perfil viajero (`traveler-profile`).
