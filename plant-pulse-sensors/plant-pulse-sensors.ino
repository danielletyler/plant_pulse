/*
 * Plant Monitoring System
 * 
 * This sketch reads various sensor data (temperature, humidity, light, soil moisture)
 * and publishes it to an MQTT broker. It can be triggered by direct MQTT messages
 * or periodic commands.
 */

#include <WiFi.h>

// Wi-Fi Configuration
const char* WIFI_SSID = "******";
const char* WIFI_PASSWORD = "********";

// MQTT Configuration
const char* MQTT_BROKER = "*******";
const int MQTT_PORT = 8883;
const char* MQTT_USERNAME = "******";
const char* MQTT_PASSWORD = "******";

// Pin Configurations
const int LIGHT_SENSOR_PIN = 36;    // GPIO36 (SVP)
const int DHT11_PIN = 21;           // GPIO21
const int SOIL_MOISTURE_PIN = 39;   // GPIO39 (SVN)

// MQTT Topics
const char* TOPIC_SUFFIX_PHOTOCELL = "/photocell";
const char* TOPIC_SUFFIX_DHT11_TEMP = "/dht11_temp";
const char* TOPIC_SUFFIX_DHT11_HUMI = "/dht11_humi";
const char* TOPIC_SUFFIX_SM_SENSOR = "/sm_sensor";
const char* TOPIC_SUFFIX_LIGHT = "/light";
const char* TOPIC_SUFFIX_TEMP = "/temp";
const char* TOPIC_SUFFIX_HUMIDITY = "/humidity";
const char* TOPIC_SUFFIX_SOIL_MOISTURE = "/soil_moisture";
const char* PERIODIC_PREFIX = "periodic";

void setup() {
    // Initialize serial communication
    Serial.begin(115200);
    Serial.println("\nStarting Plant Monitoring System...");

    // Connect to WiFi
    Serial.print("Connecting to WiFi");
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("\nConnected to Wi-Fi");

    // Initialize sensors
    setupSensors();
    Serial.println("Sensors initialized");
    
    // Setup MQTT
    setupMQTT();
    
    // Setup MQTT topics with MAC address
    String macAddress = WiFi.macAddress();
    Serial.println("MAC Address: " + macAddress);
    setupMQTTTopics(macAddress);
    Serial.println("MQTT setup complete");
}

void loop() {
    handleMQTT();
}
