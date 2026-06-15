# Fase 4F.1: Correcciones críticas pre-APK

## 1. Resumen Ejecutivo
Esta fase se enfocó íntegramente en sanear el frontend eliminando todos los remanentes de "lógica de maqueta" (mock fallbacks silenciosos) y "demo-gates" (verificaciones como `U000`), garantizando que la aplicación reaccione honestamente a la API e implementando resiliencia mediante configuraciones de entorno (`API_BASE_URL` y `USE_MOCK_FALLBACK`). Se estandarizaron las llamadas a la acción (UX de Reseñas) y se aseguró de que no se persistieran contraseñas en memoria a largo plazo.

## 2. Archivos Modificados

### Lógica de Gates (`startsWith('U000')`)
Se han purgado todas las validaciones estáticas de ID del cliente, apoyando la seguridad únicamente en la validez del JWT devuelto por el backend.
- `lib/views/feedback/feedback_screen.dart`
- `lib/controllers/profile_controller.dart`
- `lib/controllers/my_reviews_controller.dart`
- `lib/controllers/auth_controller.dart`

### Configuración de Entorno (Environment)
- `lib/integration/api/api_config.dart`

### Fallback Mocks y Explicabilidad Real
Se inyectó control a la variable `USE_MOCK_FALLBACK` y se cambió la dependencia de explicación de usuario demo a los datos obtenidos en `/recommendations/me`. 
- `lib/integration/services/destination_service.dart`
- `lib/integration/services/recommendation_service.dart`
- `lib/integration/services/profile_service.dart`
- `lib/controllers/search_controller.dart`

### UX Reseñas y Password Local
- `lib/views/destination/destination_detail_screen.dart`: Eliminado el botón flotante redundante de feedback en favor del botón contextual en la pestaña Opiniones. El Bottom Bar ahora expone "Añadir a favoritos".
- `lib/models/user_model.dart`: Removida la variable `password` de las instancias locales para evitar persistencias indeseadas en `SharedPreferences`.

## 3. Configuración de Entorno (Políticas)

### API_BASE_URL
La aplicación ya no depende del `10.0.2.2` quemado. Acepta el flag inyectado al compilar:
- **Producción:** `flutter build apk --dart-define=API_BASE_URL=https://api.proxvel.com/api/v1`
- **Físico/Local:** `flutter run --dart-define=API_BASE_URL=http://<TU_IP>:8000/api/v1`
*(Si se omite, caerá en el default histórico del emulador).*

### USE_MOCK_FALLBACK
Iniciada en `false` por defecto. 
- Al tener `USE_MOCK_FALLBACK=false` y apagar el backend, las listas regresan vacías o se arrojan excepciones controladas, mostrándose un "Empty State" real (ej. "No hay destinos disponibles").
- Al activar `USE_MOCK_FALLBACK=true` de forma explícita, los servicios (como recomendaciones, perfiles o mapas) recurrirán a los mocks en caso de que la red falle.

## 4. Resultado de Validaciones

### Pruebas Funcionales
- **Registro/Login Real:** Operacional. El registro guarda el usuario sin caché de contraseñas, permitiendo Auto-login sin fricción usando solo el token JWT.
- **Ruta Explicabilidad:** Funciona correctamente consumiendo los resultados de `/recommendations/me`. Si un lugar no fue procesado contextualmente, indica: *"Aún no hay explicación personalizada disponible para este destino"*.
- **Backend Apagado (Mock=false):** El app devuelve Empty States transparentes (ej. "Aún no hay opiniones para este destino", Listas de inicio vacías).
- **Backend Apagado (Mock=true):** Renderiza los JSONs `mock_destination_data_source.dart`, volviendo a poblar el Home para simulaciones (probado exitosamente).

### Scripts Nativos
* **`python -m compileall app`**: Exitoso (Compilación cache en backend sin sintaxis rota).
* **`flutter analyze`**: Finalizado con Info/Warnings pasivos, arrojando *18 issues* en total, consistentes en deprecaciones de `withOpacity` y unos cuantos parámetros huérfanos heredados en vistas de mapa en las cuales se aconseja migrar a `.withValues()`. **No impiden en absoluto la construcción del APK.**

## 5. Veredicto Final

**[ VEREDICTO: LISTO PARA BUILD APK ]**

El frontend ahora obedece al comportamiento tradicional cliente-servidor (C/S). Ha dejado de pretender que los datos existen si no le son proveídos, garantizando a QA que la aplicación en el APK final consumirá verdaderamente el backend Cloud asignado.
