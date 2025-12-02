# Estación Meteorológica con Flutter y ESP32

Este proyecto es una aplicación de estación meteorológica creada con Flutter, diseñada para mostrar datos de temperatura, humedad y presión. La aplicación cuenta con una interfaz de usuario moderna y personalizable, y está preparada para recibir datos de un microcontrolador ESP32 con sensores.

## Características

### Aplicación Flutter

- **Interfaz de Usuario Atractiva:** Un diseño limpio y moderno con una paleta de colores rojo, blanco y negro.
- **Visualización de Datos:** Muestra la temperatura, humedad y presión actuales, junto con un pronóstico semanal simulado.
- **Gestión de Estado:** Utiliza el paquete `provider` para gestionar el estado de la aplicación de forma eficiente.
- **Simulación de Datos:** Incluye un servicio meteorológico simulado (`WeatherService`) que imita la recepción de datos, lo que permite desarrollar y probar la interfaz de usuario sin necesidad de hardware.
- **Temas Personalizados:** Soporte para modos claro y oscuro, definidos en `lib/theme.dart`.

### Código de Arduino (ESP32)

- **Lectura de Sensores:** Se proporciona un archivo de ejemplo, `esp32_weather_station.ino`, para leer datos de un sensor BME280 (temperatura, humedad y presión).
- **Comunicación Serie:** El código de ejemplo envía los datos leídos a través del puerto serie, lo que facilita la depuración y la visualización de los datos del sensor.

## Estructura del Proyecto

- `lib/main.dart`: El punto de entrada de la aplicación Flutter. Contiene el modelo de datos (`Weather`), el servicio de simulación (`WeatherService`), el gestor de estado (`WeatherProvider`) y la interfaz de usuario (`HomePage`).
- `lib/theme.dart`: Define los temas para los modos claro y oscuro de la aplicación.
- `esp32_weather_station.ino`: El código de Arduino para el microcontrolador ESP32.
- `pubspec.yaml`: Define las dependencias del proyecto, incluyendo `provider` y `google_fonts`.

## Estado del Proyecto

La aplicación Flutter está completamente funcional con datos simulados. Puedes ejecutarla en un emulador o dispositivo para ver la interfaz de usuario y la lógica de la aplicación en acción.

**El código de Arduino (`esp32_weather_station.ino`) es un punto de partida y aún no ha sido probado con hardware real.**

### Próximos Pasos

1.  **Probar el Código de Arduino:**
    - Conectar un sensor BME280 a un ESP32.
    - Instalar las librerías necesarias en el IDE de Arduino: "Adafruit BME280 Library" y "Adafruit Unified Sensor Library".
    - Cargar el sketch `esp32_weather_station.ino` en el ESP32 y verificar que los datos se imprimen correctamente en el monitor serie.

2.  **Integrar el ESP32 con la Aplicación Flutter:**
    - Modificar el código del ESP32 para enviar los datos a través de Bluetooth Low Energy (BLE) o Wi-Fi.
    - Actualizar el `WeatherService` en la aplicación Flutter para recibir los datos del ESP32 en lugar de usar datos simulados.
