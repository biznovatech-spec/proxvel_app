# Reporte de Fase 3A.3 / 3B.2-Fix: Normalización de Contrato de Perfil Viajero

## 1. Contexto y Problema Resuelto
Se detectó que el frontend recopilaba 5 preferencias base, pero el backend gestionaba 10 pesos que quedaban nulos o no alineados con la lógica real del aplicativo. Adicionalmente, el frontend permitía la selección de múltiples intereses simultáneos que se perdían bajo un simple "mixto". 

## 2. Contrato Final Implementado
Se ha establecido un nuevo contrato entre Flutter y FastAPI donde el frontend envía **únicamente** las 5 preferencias explícitas, separando lógicamente `tipo_interes` de la lista bruta de `intereses`.

```json
{
  "presupuesto": "medio",
  "dias_viaje": 3,
  "clima_preferido": "templado",
  "tipo_interes": "mixto",
  "intereses": ["naturaleza", "gastronomico"],
  "tolerancia_multitudes": "moderado"
}
```

## 3. Decisiones de Diseño sobre "Intereses"
- **Por qué `intereses` se guarda como lista:** Si un usuario escoge "Naturaleza" y "Gastronomía", reducirlo solo a `tipo_interes = "mixto"` elimina la semántica. Guardar la lista original en PostgreSQL (usando `JSON`) permite que futuras versiones del recomendador sean más granulares.
- **Por qué `tipo_interes = "mixto"` no basta por sí solo:** Porque es útil como atajo o categoría principal (si eligió solo 1, `tipo_interes` será ese único valor), pero la lista completa es vital para pesos específicos y analítica.

## 4. Migración Creada
Se generó y ejecutó una migración de Alembic en el backend (`eba1b0c8f8fd_add_dias_viaje_tipo_interes_intereses.py`) que agregó de forma segura a la tabla `traveler_profiles`:
- `dias_viaje` (INTEGER)
- `tipo_interes` (VARCHAR)
- `intereses` (JSON)

**Ningún dato existente fue destruido ni se reseteó la base de datos.**

## 5. Lógica de Derivación de Pesos
El backend centralizó una función (`derive_profile_weights`) que lee el payload y mapea las variables a los 10 pesos internos ABSA. Reglas clave implementadas:
- **Presupuesto:** Bajo sube `peso_costos` a 5.0. Alto sube `peso_alojamiento` (5.0).
- **Clima:** Elecciones específicas clavan el `peso_clima` en 5.0.
- **Multitudes:** Tolerancia "baja" clava `peso_aforo_multitudes` en 5.0.
- **Intereses:** Itera sobre la lista `intereses` elevando pesos específicos (ej: "aventura" sube `accesibilidad` y `seguridad`, "naturaleza" sube `atractivos` y `clima`, "gastronomía" sube `gastronomía`).
- Todo valor final se garantiza en el rango de `[1.0 - 5.0]`.

## 6. Validaciones

### 6.1. Validación Postman (Python Audit Script)
Ejecuté la validación de `POST /api/v1/users` y `PUT /api/v1/users/{id}/traveler-profile` simulando la conexión exacta. 
- **`PUT` resultó en 200 OK**, guardando perfectamente `tipo_interes = "mixto"` y la matriz `["naturaleza", "gastronomico"]`.
- **`GET` subsecuente (200 OK)** retornó el payload limpio, más todos los 10 pesos exitosamente derivados (Ej: `peso_gastronomia = 5.0` y `peso_atractivos = 4.5`).

### 6.2. Validación Flutter
- Todos los modelos y vistas (`ProfileScreen`, `PreferencesScreen`, `TravelerProfileSummaryCard`, `OnboardingProfileScreen`) fueron refactorizados para usar la nomenclatura oficial (`presupuesto`, `climaPreferido`, `toleranciaMultitudes`, etc).
- Flutter ya no envía los 10 pesos, delegando completamente la responsabilidad al backend.
- `flutter analyze` reportó exitosamente **0 issues**.

## 7. Confirmaciones Técnicas
- [x] Backend recompilado y validado (`python -m compileall app`).
- [x] Contenedor backend reconstruido en caliente.
- [x] **NO se implementó JWT.**
- [x] **NO se eliminó U00001.** Sigue allí para las pruebas demo.

## Conclusión y Siguientes Pasos
El contrato de Perfil Viajero ahora es **robusto, extensible y realista**. Flutter envía la verdad del usuario y el backend computa la heurística. 
Ahora **sí estamos listos para que ejecutes la prueba visual del registro + onboarding desde tu emulador**, para verificar y dar por cerrada esta fase 3A.3/3B.2-Fix. Tras tu confirmación, podremos planificar la Fase 3B.3.
