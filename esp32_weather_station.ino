// Código para ESP8266 con sensor de Temperatura y Humedad (DHT22/DHT11)
// Envía los datos a Firebase Realtime Database
// VERSIÓN CORREGIDA #2 - COMPATIBLE CON LIBRERÍA FIREBASE ACTUALIZADA

// --- LIBRERÍAS NECESARIAS ---
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <DHT.h>

// --- CONFIGURACIÓN DEL USUARIO (¡MODIFICA ESTOS VALORES!) ---

// 1. Configuración de tu red Wi-Fi
#define WIFI_SSID "S21"
#define WIFI_PASSWORD "lll90222"

// 2. Configuración de Firebase
#define API_KEY "AIzaSyAehjLpZLbPeXrT2j5fKcf8Cr4cT46asfY" 
#define DATABASE_URL "https://meteorolocal-default-rtdb.firebaseio.com"

// 3. Configuración del Sensor DHT
#define DHTPIN 4       // Pin digital D2 en la placa NodeMCU (corresponde a GPIO4)
#define DHTTYPE DHT11  // Cambia a DHT11 si usas ese sensor.

// --- OBJETOS GLOBALES ---

DHT dht(DHTPIN, DHTTYPE);
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// --- FUNCIÓN DE INICIALIZACIÓN ---

void setup() {
  Serial.begin(115200);
  while (!Serial) { ; }

  Serial.println("Estación Meteorológica ESP8266 - Conectando...");

  dht.begin();
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Conectando a Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Conectado con IP: ");
  Serial.println(WiFi.localIP());

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

   /* Assign the user sign in credentials */
  auth.user.email = "esp32@inacap.cl";
  auth.user.password = "123456";


  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

// --- BUCLE PRINCIPAL ---

void loop() {
  delay(300); 

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Error al leer el sensor DHT!");
    return;
  }

  Serial.print("Humedad: ");
  Serial.print(humidity);
  Serial.print(" %\t");
  Serial.print("Temperatura: ");
  Serial.print(temperature);
  Serial.println(" *C");

  FirebaseJson json;
  json.set("temperature", temperature);
  json.set("humidity", humidity);

  Serial.println("Enviando datos a Firebase...");
  
  // --- LÍNEA CORREGIDA ---
  // Se han quitado los símbolos '&' de fbdo y json para usar referencias en lugar de punteros.
  if (Firebase.setJSON(fbdo, "sensor_data", json)) {
    Serial.println("-> Datos enviados correctamente");
  } else {
    Serial.println("-> Error al enviar datos");
    Serial.println("RAZÓN: " + fbdo.errorReason());
  }
}
