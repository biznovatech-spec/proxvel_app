# Reporte de Auditoría: Fase 3B.7A — Saneamiento Pre-JWT

## 1. Resumen Ejecutivo
Se realizó una introspección detallada a la base de datos PostgreSQL de PROXVEL (esquema `public`) con el propósito de identificar y aislar datos residuales generados durante las fases de pruebas unitarias, manuales y de validación End-to-End. El objetivo es estructurar un plan de limpieza de registros "basura" antes de iniciar la migración final hacia el sistema JWT, protegiendo las entidades analíticas base (catálogo turístico, matriz ABSA y rankings).

## 2. Tablas Revisadas
Se auditó la correlación transaccional sobre las tablas donde el usuario es el maestro:
- `users`
- `traveler_profiles`
- `reviews`
- `review_aspect_ratings`
- `favorites` (Actualmente vacía de datos productivos reales migrados del local storage)
- *Nota: Las tablas maestras analíticas (`destinations`, `tourism_catalog`, `contextual_rankings`, etc.) se dejaron intactas fuera del escrutinio destructivo.*

## 3. Usuarios y Correos Encontrados
El análisis expuso 20 registros en la tabla `users`:

**Usuarios Semilla/Demo (Fase 2):**
1. `U00001` (demo1@proxvel.local)
2. `U00002` (demo2@proxvel.local)
3. `U00003` (demo3@proxvel.local)

**Usuarios de Prueba Backend/E2E/Ruido:**
4. `U00004` (test_mvp_auth@proxvel.com)
5. `U00005` (test_1781390160@proxvel.com)
6. `U00006` (usuario.prueba.backend@test.com)
7. `U00007` (usuario.auditoria.final@test.com)
8. `U00008` (esaugay21@gayxsiempre.com)
9. `U00009` (esaugay22@gmail.com)
10. `U00010` (fase3a3@test.com)
11. `U00011` (erick.mendoza@upeu.edu.pe)
12. `U00012` (alexis.yunca@upeu.edu.pe)
13. `U00013` (daniel.morales@upeu.edu.pe)
14. `U00014` (dansiel.morales@upeu.edu.pe)
15. `U00015` (sfdsdfygmsil.com)
16. `U00016` (as@gmail.com)
17. `U00017` (wdf@gmail.com)
18. `U00018` (erick.ojeda@gmail.com)
19. `U00019` (e2e.proxvel.test@gmail.com)
20. `U00020` (e2e.proxvel.test2@gmail.com)

## 4. Relaciones por Usuario Detectadas
- Los usuarios base (`U00001` al `U00003`) tienen perfiles vigentes y suman 12 reseñas de prueba.
- Todos los usuarios basura/prueba (`U00004` al `U00019`) cuentan con la tabla vinculante en `traveler_profiles`.
- El usuario `U00018` posee 2 reseñas de pruebas ("esau gay").
- El usuario `U00019` posee 1 reseña de la validación end-to-end reciente.

## 5. Datos a Conservar (Lista Blanca)
- **Mantener a los usuarios semilla:** `U00001`, `U00002` y `U00003`. Su correo es `*.local` y son seguros como data de relleno para verificar que los algoritmos de recomendación/opiniones siguen funcionando mientras no haya una gran masa de usuarios reales.
- **Mantener todos los destinos, aspectos y catálogo intactos.**

## 6. Datos a Eliminar (Lista Negra)
- Todos los usuarios desde el `U00004` hasta el `U00020`. 
- Esto limpiará los correos inválidos, los textos vulgares en nombres/opiniones y los registros de las validaciones pasadas, ofreciendo un lienzo limpio para la fase JWT.

## 7. Plan Seguro de Eliminación (Orden Transaccional)
Para evitar violaciones a `FOREIGN KEY` (independientemente de si existe `ON DELETE CASCADE`), se recomienda un borrado manual ascendente:
1. Eliminar de `review_aspect_ratings` (las hijas de las reviews que se van a eliminar).
2. Eliminar de `reviews` donde el `user_id >= U00004`.
3. Eliminar de `favorites` donde el `user_id >= U00004`.
4. Eliminar de `traveler_profiles` donde el `user_id >= U00004`.
5. Eliminar de `users` donde el `user_id >= U00004`.

## 8. Riesgos y Consideraciones
- **Riesgo Nulo:** Dado que esta cirugía solo apuntará a registros insertados manualmente o mediante el frontend durante pruebas, no afectará a los datos base insertados por los seeders principales (como Destinos).
- **Consideración:** El campo transaccional serial (en caso de que `user_id` fuese un autoincrement numérico) se movería, pero como en PROXVEL el `user_id` se autogenera con formato `U00XXX` basado en el conteo máximo o UUID recortado, las siguientes creaciones tomarán de nuevo a partir de `U00004` de forma limpia.

## 9. Propuesta de Script para Fase 3B.7B
Se sugiere crear un archivo Python llamado `backend/saneamiento_pre_jwt.py` con el motor de SQLAlchemy nativo que ejecute la transacción SQL mencionada:
```python
# Ejemplo del núcleo de limpieza a emplear en la fase B
conn.execute(text("DELETE FROM review_aspect_ratings WHERE review_id IN (SELECT review_id FROM reviews WHERE user_id NOT IN ('U00001', 'U00002', 'U00003'))"))
conn.execute(text("DELETE FROM reviews WHERE user_id NOT IN ('U00001', 'U00002', 'U00003')"))
conn.execute(text("DELETE FROM traveler_profiles WHERE user_id NOT IN ('U00001', 'U00002', 'U00003')"))
conn.execute(text("DELETE FROM users WHERE user_id NOT IN ('U00001', 'U00002', 'U00003')"))
conn.commit()
```

## 10. Confirmaciones Finales
- **Confirmado**: NO se ejecutó ningún `DELETE`, `TRUNCATE` ni mutación durante esta fase. La base de datos sigue intacta.
- **Confirmado**: NO se tocó ninguna línea de código de Flutter (frontend).
- **Confirmado**: NO se ha iniciado la implementación de JWT.

La base de datos de pruebas está diagnosticada y lista para limpieza controlada.
