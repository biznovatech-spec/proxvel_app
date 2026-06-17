# Reporte de Entendimiento: Lógica de Recomendación y Flujos de PROXVEL

Este documento demuestra mi comprensión absoluta de las directrices que me has dado. Lo he redactado "con lupa" para que confirmes que estamos totalmente alineados antes de tocar una sola línea de código o plantear la implementación técnica.

## 1. El Concepto Central: Separación de Experiencias
Entiendo perfectamente el problema actual: la aplicación se sentía restrictiva porque estábamos forzando la IA en toda la experiencia. PROXVEL debe funcionar como una **app de turismo clásica y completa** para el público general, pero que guarda su poderoso **motor de IA en apartados específicos y opcionales**, brillando únicamente donde el usuario realmente lo pide o necesita.

Hemos dividido la aplicación en dos grandes flujos:

### Flujo A: Experiencia Clásica (Catálogo Abierto)
Es el comportamiento por defecto de la app. El usuario tiene total libertad para ver absolutamente todo el catálogo, sin que la IA lo filtre, limite u ordene arbitrariamente.

### Flujo B: Experiencia Inteligente (Recomendación por IA)
Es la experiencia enriquecida por la tesis. Solo actúa si el usuario tiene sus **aspectos/preferencias completados**. Toma esos datos y reordena el mundo turístico para que haga "match" perfecto con el viajero.

---

## 2. Análisis y Solución de Flujos y Vistas

### A. La pestaña "Para ti" -> Ahora "Recomendación IA"
*   **Renombramiento:** Cambiaremos el nombre a "Recomendación IA" para dejar claro cuál es el objetivo de esta sección.
*   **El bloqueo (Empty State):** Si el usuario le dio a "Omitir" al inicio y no tiene sus aspectos rellenados, esta vista **no le mostrará nada del catálogo**. Mostrará un mensaje claro y amigable indicando: *"Te falta completar tus aspectos viajeros para generar tus recomendaciones por IA"*, junto a un botón que lo lleve a rellenarlos.
*   **Con aspectos listos:** Si los rellenó, se muestra exactamente como funciona ahora: mostrando las Cards especializadas que tienen la compatibilidad, el porcentaje de match y por qué se le recomienda.

### B. La pestaña "Explorar" (El Home clásico)
*   **Libertad total:** Aquí no hay restricciones. Todos los destinos deben listarse (novedades, temporada, cerca de ti). 
*   **Rediseño de la Card clásica:**
    *   **Fuera precios falsos:** Quitaremos precios irrelevantes para dejar un diseño más limpio y directo.
    *   **IA de forma sutil:** La métrica gigante del porcentaje de recomendación (el "match") no debe ser la estrella aquí. La moveremos a la parte inferior de la tarjeta y la haremos más pequeña, discreta. El protagonista debe ser el destino, su foto y su nombre.
*   **Vista de Detalle de Destino (Modo Informativo):** Si un usuario entra al detalle de un destino desde la pestaña "Explorar", la jerarquía de la información cambia. Lo primero que verá es la descripción, el clima, las fotos y los datos turísticos. El bloque de *"¿Qué tan compatible es contigo según la IA?"* pasará al **final de la pantalla** como un dato curioso y de apoyo, y no como el bloque principal.

### C. La Búsqueda y los Filtros
*   **Búsqueda normal:** Al tipear "Cusco", la app arroja todos los destinos relacionados a Cusco de manera normal.
*   **El *Toggle* (Interruptor) de IA:** Añadiremos un botón deslizable o checkbox rápido en la pantalla de filtros/búsqueda que diga *"Ordenar por recomendación IA"*.
    *   **Desactivado (por defecto):** Lista alfabéticamente o por cercanía.
    *   **Activado:** Agarra la lista de resultados de Cusco y **coloca primero los que hacen mejor match** con los aspectos del viajero.

### D. Configuración Global en el Perfil
*   **El Ajuste (Switch) Maestro:** En la vista de "Configuración" o "Mis preferencias" en el Perfil del usuario, agregaremos un switch: *"Aplicar Recomendación IA en toda la app"*.
*   **Efecto:** Si el usuario activa esto, está decidiendo que quiere que la IA guíe *todo* su viaje. Si está activo, entonces la pestaña "Explorar" y las búsquedas tendrán en cuenta su porcentaje de compatibilidad de forma automática y prominente.
*   **Aislamiento de "Recomendación IA":** Independientemente de si este botón global está apagado, la pestaña principal de "Recomendación IA" (la antigua "Para ti") **siempre usará la IA**. No se ve afectada por el apagado global, porque entrar a esa pestaña es, por definición, pedirle recomendaciones a la máquina.

---

## 3. Limpieza y Relevancia de Datos
Mencionaste que en iteraciones pasadas, por rellenar el diseño, "pusimos cualquier cosa" o no tuvimos en cuenta el sentido real de la recomendación. Entiendo la orden: **todo debe tener sentido**.
*   Eliminaremos campos genéricos en las UI de tarjetas que no aportan valor.
*   Nos aseguraremos de que los flujos no se mezclen. Si es modo informativo, damos información cruda. Si es modo IA, damos contexto y métricas de recomendación.

---

### ¿Cómo procederemos?
Si apruebas este entendimiento del negocio, el siguiente paso será crear el **Plan de Implementación Técnico**, donde definiremos qué archivos `.dart` modificar, cómo gestionar los estados globales para el nuevo switch en el perfil, y cómo desdoblar las Cards en dos widgets distintos (`ClassicDestinationCard` vs `AiRecommendationCard`).

Por favor revisa este reporte y confírmame si capturé al 100% la visión que tienes para la plataforma.
