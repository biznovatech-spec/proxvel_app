# Reporte de Fix: Fase 3B.3 — Desalineamiento de Intereses ("compras")

Este documento detalla la investigación y solución definitiva a la inconsistencia reportada en la cual intereses no visibles (como `"compras"`) aparecían mágicamente en el backend a pesar de no estar seleccionados en la interfaz de usuario en `PreferencesScreen`.

## 1. Causa Raíz del Problema

La investigación exhaustiva del flujo de datos reveló lo siguiente:

1. **¿Venía del Backend o un merge?**
   No. El backend en el endpoint `PUT /traveler-profile` usa `setattr(profile, "intereses", ...)` lo cual reemplaza por completo la lista en PostgreSQL y es detectado correctamente por SQLAlchemy. Se comprobó mediante script manual de peticiones HTTP que el backend sí elimina "compras" si el payload de entrada no lo trae.

2. **¿Venía del Frontend?**
   **Sí.** El problema originario se debía a la forma en la que la pantalla cargaba los intereses anteriormente:
   ```dart
   _interests = List.from(profile.intereses); // Estado anterior al fix UX
   ```
   Esta instrucción tomaba *todos* los intereses provenientes del backend (incluyendo "compras" si el usuario lo había insertado manualmente o venía de un mock/Postman antiguo). 
   Dado que "compras" no pertenece a `_allInterests`, el chip nunca se dibujaba en la UI. Sin embargo, "compras" **seguía vivo de manera invisible** dentro de la variable `_interests` en Flutter.
   
   Al darle clic a "Guardar Preferencias", el frontend agarraba la lista invisible contaminada y la mandaba íntegra al backend:
   ```json
   "intereses": ["cultura", "gastronomia", "compras"]
   ```

## 2. Solución y Mapeo Seguro

El fix de Mapeo Visual que apliqué en el turno anterior ya había atajado el problema mitigándolo en el momento de la carga (`_loadCurrentPreferences` ahora desecha todo valor que no concuerde con `_allInterests` devolviendo `null` a través de `_matchOption` y limpiándolo con `.where((i) => i != null)`). 

Sin embargo, para garantizar una arquitectura defensiva al 100%, se ha agregado un **filtro estricto final antes de disparar el payload HTTP**:

```dart
final validInterests = _interests
    .where((i) => _allInterests.contains(i))
    .map((e) => e.toLowerCase().replaceAll('í', 'i'))
    .toList();
```

Esto garantiza matemáticamente que el payload `PREFERENCES SAVE BODY` que emite Flutter jamás envíe strings intrusos. 

## 3. Lista Final de Intereses Permitidos

El contrato estricto de opciones que domina la UI y que el backend recibirá obedece exclusivamente a:
- playa
- montaña
- ciudad
- aventura
- cultura
- gastronomia
- historia
- relajacion

*Nota: La opción "compras" no es válida para la UI actual y por consiguiente ha sido erradicada del flujo.*

## 4. Validaciones Técnicas y Post-Fix

- [x] **Backend intacto:** No fue necesario alterar el código del backend; su comportamiento PUT (replace) funciona perfecto.
- [x] **Calidad de Código:** `flutter analyze` finalizó con **0 issues**.
- [x] **Alineación Visual garantizada:** Ahora la regla se cumple: "Si no lo ves en la UI, no se guarda en PostgreSQL".

### Body real enviado tras el fix:
```json
{
  "presupuesto": "bajo",
  "dias_viaje": 1,
  "clima_preferido": "frio",
  "tipo_interes": "mixto",
  "intereses": ["cultura", "gastronomia"],
  "tolerancia_multitudes": "bajo"
}
```

### Respuesta de Postman tras el fix:
El array `intereses` contiene de forma purificada las opciones, purgando la variable huérfana "compras".

```json
{
  "success": true,
  "data": {
    "intereses": ["cultura", "gastronomia"],
    ...
  }
}
```
