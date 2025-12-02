
# Blueprint: Estación Meteorológica Simple con Flutter y ESP32

## Visión General

Este proyecto consiste en una estación meteorológica simple que utiliza un microcontrolador ESP32 para recopilar datos de temperatura, humedad y presión. Una aplicación móvil construida con Flutter mostrará estos datos y un pronóstico local simulado, con un diseño en rojo, blanco y negro.

## Plan de Implementación

### Fase 1: Aplicación Flutter

1.  **Configuración del Proyecto:**
    *   Añadir dependencias necesarias: `google_fonts` para tipografía y `provider` para el manejo del estado.

2.  **Diseño y Tema:**
    *   Crear un archivo `theme.dart` para definir el tema de la aplicación con una paleta de colores rojo, blanco y negro.
    *   Utilizar `google_fonts` para una tipografía moderna y legible.

3.  **Estructura de la Aplicación:**
    *   **`main.dart`**:
        *   Configurar la aplicación para usar el tema personalizado y el `WeatherProvider`.
        *   Crear un `Weather` data model para la temperatura, la humedad y la presión.
        *   Crear un `WeatherService` para simular la obtención de datos del ESP32.
        *   Crear un `WeatherProvider` para manejar el estado de los datos del clima.
        *   Diseñar la interfaz de usuario (`HomePage`) para mostrar los datos actuales (temperatura, humedad, presión) y un pronóstico simulado.
    *   **`theme.dart`**:
        *   Definir el `ThemeData` para los modos claro y oscuro, utilizando la paleta de colores rojo, blanco y negro.

### Fase 2: Código de Arduino (ESP32)

1.  **`esp32_weather_station.ino`**:
    *   Proporcionar un código de ejemplo para el ESP32.
    *   Este código incluirá placeholders para las librerías de los sensores específicos (por ejemplo, BME280 para temperatura, humedad y presión).
    *   El código estará estructurado para leer los datos de los sensores y enviarlos (por ejemplo, a través de `Serial` para depuración, pero se puede adaptar a Bluetooth o Wi-Fi).

## Características Clave del Diseño

*   **Paleta de Colores:** Rojo, blanco y negro para un aspecto moderno y de alto contraste.
*   **Tipografía:** Fuentes claras y legibles de `google_fonts`.
*   **Interfaz de Usuario:**
    *   Visualización clara de los datos actuales.
    *   Iconos para representar las condiciones climáticas.
    *   Una sección para un pronóstico simple.
