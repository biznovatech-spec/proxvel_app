# Reporte de Fix: Fase 3B.3 — Mapeo UI y Preferencias de Perfil Viajero

Este documento detalla las correcciones aplicadas a la interfaz de usuario en Flutter (UX/UI Mapping) solicitadas antes del cierre oficial de la Fase 3B.3, garantizando que lo que ve y envía el usuario esté perfectamente sincronizado con las exigencias estructurales del backend.

## 1. Problema de Nombre y Apellido (EditProfileScreen)

### Causa del Problema
El backend y la arquitectura actual (`UserModel`) unifican el nombre del usuario en el atributo `name`. Sin embargo, la interfaz de "Editar perfil" pedía visualmente "Nombre" y "Apellidos" por separado. Al cargar la pantalla, el apellido quedaba vacío y se causaba confusión porque Flutter no realizaba el desglose semántico de la cadena unificada recibida desde la API.

### Regla Final de Split Visual y Unión
Se implementó una lógica de desglose (`split(RegExp(r'\s+'))`) al cargar los datos desde la caché/red que sigue esta regla documentada:
- **1 palabra** (Ej. `"Daniel"`): Nombre = `"Daniel"`, Apellido = `""`.
- **2 palabras** (Ej. `"Daniel Morales"`): Nombre = `"Daniel"`, Apellido = `"Morales"`.
- **3 o más palabras** (Ej. `"Juan Carlos Pérez Ramos"`): Nombre = Primera palabra (`"Juan"`), Apellido = El resto de la cadena unida por espacios (`"Carlos Pérez Ramos"`). Esto garantiza un llenado seguro de los campos.

Al presionar "Guardar cambios", Flutter invoca a `AuthController.updateUserProfile` el cual vuelve a unificar `name + lastName`, ejecutando una petición `PATCH /api/v1/users/{user_id}` enviando única y puramente el atributo `name`.

### Confirmación de Solo Lectura para Email
El campo "Email" ahora porta la etiqueta explícita `Email (Solo lectura)` y su componente (`ProxvelTextField`) fue provisto del parámetro `readOnly = true`. Es ineditable en la interfaz, lo cual evita riesgos de colisión hasta que exista un sistema de cambio de cuenta seguro mediante confirmación de token.

## 2. Chips No Seleccionados (PreferencesScreen)

### Causa del Problema
Cuando el `ProfileController` cargaba el perfil desde el backend, traía las variables serializadas y minúsculas (Ej. `"clima_preferido": "frio"` o `"presupuesto": "lujo"`). El componente visual buscaba un string idéntico (case-sensitive y con acentos) entre las opciones (Ej. `"Frío"` o `"Lujo"`). Al no encontrar equivalencia binaria estricta, ningún chip se pintaba como activo.

### Solución Implementada
Se creó un procesador lógico `_matchOption` que hace coincidir la constante de la base de datos con la lista de opciones visuales ignorando mayúsculas y acentuación. Adicionalmente, incluye un diccionario lógico interno para homologar variantes semánticas ("alta" UI -> "alto" BD). Ahora, al abrir "Mis Preferencias", todos los chips se colorean indicando exactamente el estado almacenado en PostgreSQL.

## 3. Selector de Días de Viaje

Se detectó que el contrato API solicitaba `dias_viaje`, pero la UI carecía del *input*.
Se incorporó un selector horizontal `_daysOptions` idéntico al estilo arquitectónico de la app:
- Opciones: `1`, `2`, `3`, `5`, `7+`
- **Mapeo:** La elección del usuario se procesa (`parseDays`). Si escoge `7+`, Flutter envía `7` (Integer) dentro del payload JSON al backend.

## 4. Contrato Estricto (Restricciones Aplicadas)

- [x] **Flutter NO envía los 10 pesos ABSA.** Toda derivación matemática persiste encapsulada en el servicio backend FastAPI.
- [x] Flutter envía estrictamente un payload JSON en la ruta PUT con `presupuesto`, `dias_viaje`, `clima_preferido`, `tipo_interes`, `intereses` y `tolerancia_multitudes`.
- [x] Backend intacto (ningún archivo `proxvel_backend` ha sido manipulado).
- [x] Ausencia total de JWT y Login Real (Respetando regla de la fase).
- [x] `U00001` no ha sido borrado.

## 5. Validaciones Técnicas y Pruebas
1. **Calidad:** `flutter analyze` reporta gloriosamente **0 issues found!**
2. **Postman (Usuario Atualizado):** Tras la edición, al hacer GET a `/users/{user_id}`, el atributo `name` regresa unificado y consistente.
3. **Postman (Preferencias):** Al enviar desde Flutter (cambiando Días y Presupuesto), el backend devuelve las 6 variables registradas exitosamente, junto con los 10 nuevos pesos alterados orgánicamente.
