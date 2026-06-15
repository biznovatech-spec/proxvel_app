# Reporte de Planificación: Fase 3D.0 — Plan técnico de integración del motor real v0 de recomendaciones autenticadas en PROXVEL

## 1. Resumen Ejecutivo
Tras el éxito de la integración de JWT y la estabilización del flujo de autenticación, la Fase 3D.0 establece la hoja de ruta para conectar el corazón analítico de PROXVEL (el motor de recomendación Fase 4) con usuarios orgánicos reales. Actualmente, el motor opera con perfiles sintéticos pre-calculados (fallback a U00001). Esta planificación traza la estrategia para crear el endpoint autenticado `/recommendations/me`, el cual ejecutará (o adaptará) el motor *engine_v0* de forma dinámica usando el `traveler_profile` vivo del usuario logueado, sin que Flutter tenga que enviar IDs ni depender de mocks.

## 2. Estado actual del motor real v0 (Backend)
- **¿Dónde está el motor actual?** Se encuentra encapsulado en `app/repositories/db_ranking_repository.py` y `ranking_repository.py` (CSV fallback), expuesto mediante `ContextualRankingService`.
- **¿Qué entradas usa?** Requiere un `user_id` (pre-sembrado), y cruza datos con las tablas de clima y aforo (`ClimateScore`, `CrowdScore`).
- **¿Qué salida genera?** Devuelve un ranking pre-computado de destinos con puntajes de afinidad, porcentajes, etiquetas y contexto (razón climática/aforo).
- **¿Qué tan conectado está con PostgreSQL?** Totalmente conectado para lectura (lee la tabla `contextual_rankings`), pero la *generación* de esa tabla es estática (pre-seeding).
- **¿Lee `traveler_profile` real o todavía no?** **No.** Actualmente solo devuelve resultados pre-procesados para los usuarios sintéticos `U00001` a `U03000`.
- **¿Lee pesos ABSA derivados reales?** No de forma dinámica, ya están inyectados en el score final del dataset pre-calculado.
- **¿Usa matriz ABSA?** El dataset estático se basó en ella, pero el endpoint actual no la multiplica en tiempo real.
- **¿Usa clima y aforo?** **Sí**, y además enriquece la lectura dinámicamente con el mes actual en `db_ranking_repository.py`.
- **¿Usa ranking contextual?** **Sí**, es la versión de Fase 4 (combina afinidad + contexto).
- **¿Qué falta para envolverlo en FastAPI?** Falta crear el motor dinámico (adapter) que tome el perfil de viaje del usuario en PostgreSQL, obtenga los pesos ABSA, lea la matriz estática y calcule la matemática (WSM) en tiempo de ejecución, para luego devolver la lista sin necesidad de tenerla pre-calculada.

## 3. Estado actual del frontend de recomendaciones
- **¿Home “Para ti” consume backend o mock?** Consume backend (`/recommendations/contextual`) con fallback al Mock si falla.
- **¿Qué modelo espera Flutter?** Espera `RecommendationResultModel`.
- **¿Qué campos visuales necesita la card?** Nombre de destino, ciudad, imagen, `compatibilityPercentage`, `finalScore` y `shortExplanation` / `context_reason`.
- **¿Ya soporta `compatibility_percent`?** **Sí.**
- **¿Ya soporta explicación?** Soporta un texto corto y razones contextuales, pero **no** un desglose estructurado (`top_aspects`).
- **¿Ya separa recomendados de catálogo general?** **Sí**, "Para ti" vs "Explorar" operan en repositorios distintos.
- **¿Hay dependencias de `demoUserId`?** **Sí**, `RecommendationService.dart` inyecta forzosamente `ApiConfig.demoUserId` (`U00001`) si no hay ID.
- **¿Qué cambios serían necesarios para `/recommendations/me`?** Remover el parámetro `user_id`, apuntar a la nueva ruta y expandir el modelo para atrapar el bloque estructurado de explicación (`top_aspects`).

## 4. Endpoint Recomendado
**Ruta:** `GET /api/v1/recommendations/me`

### Contrato de Entrada
Ninguno en el payload ni en la URL. Solo requiere el Header HTTP:
`Authorization: Bearer <token_jwt>`

### Contrato de Salida Propuesto
```json
{
  "success": true,
  "message": "Recomendaciones personalizadas generadas correctamente",
  "engine": {
    "source": "engine_v0",
    "version": "0.1",
    "is_final_model": false,
    "metrics_status": "en_mejora"
  },
  "data": [
    {
      "destination_id": "DEST001",
      "name": "Machu Picchu",
      "city": "Cusco",
      "region": "Cusco",
      "category": "arqueológico",
      "cover_image_url": "...",
      "rating": 4.8,
      "compatibility_score": 0.92,
      "compatibility_percent": 92,
      "context_status": "verde",
      "ranking_position": 1,
      "explanation": {
        "summary": "Alta afinidad por atractivos, cultura y clima.",
        "top_aspects": [
          {
            "aspect": "atractivos",
            "user_weight": 0.95,
            "destination_score": 0.91,
            "contribution": 0.86
          }
        ]
      }
    }
  ]
}
```

## 5. Arquitectura del Flujo Dinámico (Backend)
1. **JWT (`current_user`):** FastAPI intercepta el token y extrae el `user_id`.
2. **`traveler_profile`:** El servicio consulta la DB para extraer las preferencias reales del usuario.
3. **Pesos ABSA:** Una función adaptadora mapeará las opciones del perfil (ej. prefiere "Naturaleza" = 5) a un vector de pesos matemáticos.
4. **Matriz ABSA / Clima / Aforo:** El adaptador cargará los CSV base, multiplicará el vector del usuario por los scores estáticos de los destinos (Weighted Sum Model) y aplicará los penalizadores/bonificadores climáticos del mes en curso.
5. **Respuesta:** Se ensambla el JSON ordenado y se envía a Flutter.

## 6. Riesgos Técnicos
- **Latencia Matemática:** Calcular el WSM en tiempo real usando pandas/numpy en Python durante un request HTTP puede introducir un ligero lag si la matriz crece mucho. Sin embargo, para 40 destinos, será instantáneo.
- **Ruptura de Contrato:** Si en el futuro `engine_v1` o el modelo final de Machine Learning devuelven parámetros distintos, Flutter podría romperse. El bloque `"engine": {...}` nos protegerá versionando las salidas.

## 7. Plan por Subfases Propuesto
- **Fase 3D.1:** Creación del endpoint backend `/recommendations/me` implementando la lógica matemática en tiempo real (`engine_v0`) usando pesos mapeados del perfil real + matriz estática ABSA.
- **Fase 3D.2:** Modificación en Flutter (`RecommendationService`) para consumir el nuevo endpoint protegido (remover el `demoUserId`).
- **Fase 3D.3:** Expansión visual en Flutter para mostrar la "Explicabilidad" (el desglose matemático o lógico de por qué se recomienda).
- **Fase 3D.4:** Validación End-to-End de recomendaciones dinámicas con un perfil orgánico.

## 8. Recomendación exacta para iniciar 3D.1
Se recomienda abrir la **Fase 3D.1** enfocándose estrictamente en el ecosistema **Python (FastAPI)**. Se deberá crear la ruta, el servicio calculador dinámico y el esquema Pydantic para el bloque `engine` y `explanation`. No se debe tocar Flutter hasta la 3D.2.

## 9. Confirmaciones de Restricción
- **Confirmado:** No se ha modificado ni una sola línea de código en todo el proyecto.
- **Confirmado:** No se ha ejecutado ninguna escritura ni alteración en la base de datos PostgreSQL.

## 10. Conclusión
**Fase 3D.0 cerrada.** La auditoría confirma que PROXVEL cuenta con las bases operativas de Fase 4 (clima, aforo y ranking pre-calculado), pero el eslabón faltante es la *computación matemática en tiempo real* para conectar a los viajeros reales con el motor. El plan expuesto pavimenta el camino seguro para crear esta conexión sin alterar la seguridad ni colapsar la UI móvil.
