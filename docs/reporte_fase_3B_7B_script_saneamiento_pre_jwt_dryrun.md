# Reporte de Saneamiento Pre-JWT (Modo Dry-Run): Fase 3B.7B

## 1. Resumen Ejecutivo
Se ha desarrollado un script seguro y transaccional (`saneamiento_pre_jwt.py`) con el propósito de purgar los datos basura generados durante las pruebas (usuarios ficticios, correos temporales, perfiles E2E y reseñas vulgares), dejando la base de datos limpia para la transición a autenticación JWT. La ejecución inicial del script se ha realizado estrictamente en modo simulación (`--dry-run`) para auditar los conteos y verificar el comportamiento exacto antes de comprometer cualquier mutación destructiva en PostgreSQL.

## 2. Archivo Script Creado
Se ha creado el archivo ejecutable en la ruta:
`backend/scripts/saneamiento_pre_jwt.py`

## 3. Explicación del Modo `--dry-run`
Este es el modo **predeterminado**. Si alguien invoca el script sin argumentos, se asume este modo por seguridad. Su función es conectarse a PostgreSQL usando SQLAlchemy, generar la misma cláusula `WHERE user_id NOT IN ('U00001', 'U00002', 'U00003')` que se usaría en el borrado, y consultar los contadores (`COUNT(*)`) de cada tabla dependiente. Finalmente, expone en consola lo que **se habría borrado** sin realizar ninguna alteración.

## 4. Explicación del Modo `--execute`
Solo puede invocarse explícitamente pasando el flag `--execute`. Su flujo interno es:
1. Abre una transacción protegida (`with conn.begin():`).
2. Ejecuta 5 sentencias `DELETE` encadenadas, empezando por las tablas más bajas en la jerarquía (evitando choques de `FOREIGN KEY`).
3. Si ocurre algún error a nivel relacional, la transacción falla íntegramente (Rollback) garantizando que no queden datos huérfanos.
4. Si todo es exitoso, realiza el `Commit` final y muestra el conteo de usuarios restantes.

## 5. Usuarios Whitelist (Conservados)
La configuración estricta protege exclusivamente a los usuarios semilla originales, evadiendo la lógica de "mayor a U00004":
- `U00001` (demo1@proxvel.local)
- `U00002` (demo2@proxvel.local)
- `U00003` (demo3@proxvel.local)

## 6. Usuarios Candidatos a Eliminar (Lista Negra)
El escaneo en vivo del script detectó a los siguientes 17 usuarios como basura:
- `U00004` (test_mvp_auth@proxvel.com)
- `U00005` (test_1781390160@proxvel.com)
- `U00006` (usuario.prueba.backend@test.com)
- `U00007` (usuario.auditoria.final@test.com)
- `U00008` (esaugay21@gayxsiempre.com)
- `U00009` (esaugay22@gmail.com)
- `U00010` (fase3a3@test.com)
- `U00011` (erick.mendoza@upeu.edu.pe)
- `U00012` (alexis.yunca@upeu.edu.pe)
- `U00013` (daniel.morales@upeu.edu.pe)
- `U00014` (dansiel.morales@upeu.edu.pe)
- `U00015` (sfdsdfygmsil.com)
- `U00016` (as@gmail.com)
- `U00017` (wdf@gmail.com)
- `U00018` (erick.ojeda@gmail.com)
- `U00019` (e2e.proxvel.test@gmail.com)
- `U00020` (e2e.proxvel.test2@gmail.com)

## 7. Conteo Dry-Run por Tabla (Impacto Real)
El escaneo de las dependencias arrojó las siguientes magnitudes de purga inminente:
- **`review_aspect_ratings`**: 0
- **`reviews`**: 3 (Eliminará las pruebas vulgares y validaciones E2E).
- **`favorites`**: 0
- **`traveler_profiles`**: 15
- **`users`**: 17

## 8. Confirmaciones de Integridad
- **Confirmado**: MODO DRY-RUN: no se eliminó ningún dato.
- **Corrección de `favorites`**: El código SQL dentro de la simulación y ejecución sí incluyó explícitamente el `DELETE FROM favorites` tal como fue solicitado, antes de saltar a `traveler_profiles`.
- **Estado de `U00020`**: El script detectó que el usuario E2E generado tiene cuenta en `users` pero contribuye con `0` a perfiles y reseñas. No obstante, caerá en la purga correctamente al no pertenecer a la Whitelist.

## 9. SQL de Validación Posterior
Una vez se apruebe y ejecute el modo `--execute`, las siguientes consultas manuales deben dar como resultado solo a U00001, U00002 y U00003:
```sql
SELECT user_id, name, email FROM users ORDER BY user_id;
SELECT user_id, COUNT(*) FROM traveler_profiles GROUP BY user_id ORDER BY user_id;
SELECT user_id, COUNT(*) FROM reviews GROUP BY user_id ORDER BY user_id;
SELECT r.user_id, COUNT(rar.*) FROM review_aspect_ratings rar JOIN reviews r ON r.review_id = rar.review_id GROUP BY r.user_id ORDER BY r.user_id;
SELECT user_id, COUNT(*) FROM favorites GROUP BY user_id ORDER BY user_id;
```

## 10. Riesgos
- **Riesgo:** Pérdida accidental de la base de datos si ocurre un error sistémico irrecuperable en el servidor local.
- **Riesgo:** Reinicio de contadores no secuenciales que pueda afectar lógicas si se depende de ellos numéricamente (aunque PROXVEL genera UUIDs custom con base en un offset, lo que mitiga este problema de forma automática).

## 11. Recomendación Previa a Purga Real
**OBLIGATORIO**: Se recomienda encarecidamente la realización de un backup (ej: `pg_dump -U proxvel_user -h localhost proxvel_db > backup_pre_jwt.sql`) sobre el contenedor PostgreSQL antes de invocar el flag `--execute`.

## 12. Confirmaciones Finales
- **Confirmado**: NO se tocó ninguna línea de código del frontend (Flutter).
- **Confirmado**: NO se implementó JWT en el backend en absoluto.

## 13. Conclusión
**Fase 3B.7B cerrada en su etapa de diagnóstico y simulación.** El script seguro está desplegado y verificado. Quedo a la espera de la autorización explícita para lanzar el modo `--execute`.
