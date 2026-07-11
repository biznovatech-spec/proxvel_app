# Fuente del Catálogo de Residencia (UBIGEO Perú)

- **Fuente exacta usada:** Dataset "ubigeo-peru-aumentado" consolidado de INEI/RENIEC (2016-2020).
- **Autor original / Repositorio:** Jesus M. Castagnetto (`jmcastagnetto/ubigeo-peru-aumentado`)
- **URL / Referencia:** https://github.com/jmcastagnetto/ubigeo-peru-aumentado
- **Fecha de consulta:** 11 de Julio de 2026
- **Licencia:** MIT License (según repositorio origen). Los datos en sí son de dominio público (Datos Abiertos del Estado Peruano - INEI/RENIEC).
- **Nota técnica:** El campo `ubigeo` se usa internamente en la aplicación de Flutter para mantener la integridad relacional de los dropdowns y como identificador único para prevenir duplicados. Sin embargo, no se expone visualmente al usuario ni se envía al backend todavía, ya que en la Fase 1C el contrato backend requiere solo los nombres (`residence_department`, `residence_province`, `residence_city`).
