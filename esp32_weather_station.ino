
// Este es un código de ejemplo para un ESP32 que lee datos de un sensor BME280
// y los envía a través del puerto serie. Necesitarás instalar las librerías
// "Adafruit BME280 Library" y "Adafruit Unified Sensor Library".

#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BME280.h>

// Dirección I2C del sensor BME280. Puede ser 0x76 o 0x77.
#define BME_I2C_ADDRESS 0x76

Adafruit_BME280 bme; // Objeto para el sensor

void setup() {
  Serial.begin(115200);
  while (!Serial) {
    ; // Espera a que el puerto serie se conecte
  }

  Serial.println("Estación Meteorológica ESP32");

  if (!bme.begin(BME_I2C_ADDRESS)) {
    Serial.println("No se pudo encontrar un sensor BME280 válido, ¡revisa el cableado!");
    while (1);
  }
}

void loop() {
  // Lee los datos del sensor
  float temperature = bme.readTemperature();
  float humidity = bme.readHumidity();
  float pressure = bme.readPressure() / 100.0F; // Convierte a hPa

  // Imprime los datos en el monitor serie
  Serial.print("Temperatura: ");
  Serial.print(temperature);
  Serial.println(" *C");

  Serial.print("Humedad: ");
  Serial.print(humidity);
  Serial.println(" %");

  Serial.print("Presión: ");
  Serial.print(pressure);
  Serial.println(" hPa");

  Serial.println();

  // Espera 2 segundos antes de la siguiente lectura
  delay(2000);
}
