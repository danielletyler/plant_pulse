#include <DHT.h>

// Initialize DHT sensor
DHT dht(DHT11_PIN, DHT11);

void setupSensors() {
    // Configure pins and sensors
    pinMode(LIGHT_SENSOR_PIN, INPUT);
    dht.begin();
    analogSetAttenuation(ADC_11db);  // Set attenuation for ESP32 ADC
}

float readTemperature() {
    return dht.readTemperature(true);  // true for Fahrenheit
}

float readHumidity() {
    return dht.readHumidity();
}

int readLightLevel() {
    int rawValue = analogRead(LIGHT_SENSOR_PIN);
    // Map raw value (0-4095) to a more manageable range (0-30)
    return map(rawValue, 0, 4095, 0, 30);
}

int readSoilMoisture() {
    return analogRead(SOIL_MOISTURE_PIN);
} 