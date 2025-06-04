#include <WiFiClientSecure.h>
#include <PubSubClient.h>

// Global MQTT objects
WiFiClientSecure wifiClient;
PubSubClient mqttClient(wifiClient);

// Topic strings for this device
String topicPhotocell, topicDHT11Temp, topicDHT11Humi, topicSMSensor;
String topicPublishLight, topicPublishTemp, topicPublishHumidity, topicPublishSM;

void setupMQTTTopics(const String& macAddress) {
    // Setup subscription topics
    topicPhotocell = macAddress + TOPIC_SUFFIX_PHOTOCELL; //##:##:##:##:##:##/photocell
    topicDHT11Temp = macAddress + TOPIC_SUFFIX_DHT11_TEMP;
    topicDHT11Humi = macAddress + TOPIC_SUFFIX_DHT11_HUMI;
    topicSMSensor = macAddress + TOPIC_SUFFIX_SM_SENSOR;
    
    // Setup publishing topics
    topicPublishLight = macAddress + TOPIC_SUFFIX_LIGHT; //##:##:##:##:##:##/light
    topicPublishTemp = macAddress + TOPIC_SUFFIX_TEMP;
    topicPublishHumidity = macAddress + TOPIC_SUFFIX_HUMIDITY;
    topicPublishSM = macAddress + TOPIC_SUFFIX_SOIL_MOISTURE;
}

void setupMQTT() {
    wifiClient.setInsecure();  // Note: Use proper certificate validation in production
    mqttClient.setServer(MQTT_BROKER, MQTT_PORT);
    mqttClient.setCallback(mqttCallback);
}

void subscribeToTopics() {
    // Subscribe to device-specific topics
    mqttClient.subscribe(topicPhotocell.c_str());
    mqttClient.subscribe(topicDHT11Temp.c_str());
    mqttClient.subscribe(topicDHT11Humi.c_str());
    mqttClient.subscribe(topicSMSensor.c_str());
    
    // Subscribe to periodic topics
    mqttClient.subscribe((String(PERIODIC_PREFIX) + TOPIC_SUFFIX_PHOTOCELL).c_str());
    mqttClient.subscribe((String(PERIODIC_PREFIX) + TOPIC_SUFFIX_DHT11_TEMP).c_str());
    mqttClient.subscribe((String(PERIODIC_PREFIX) + TOPIC_SUFFIX_DHT11_HUMI).c_str());
    mqttClient.subscribe((String(PERIODIC_PREFIX) + TOPIC_SUFFIX_SM_SENSOR).c_str());
}

void reconnectMQTT() {
    while (!mqttClient.connected()) {
        Serial.println("Reconnecting to MQTT Broker...");
        String clientId = "ESP32Client-" + String(random(0xffff), HEX);

        if (mqttClient.connect(clientId.c_str(), MQTT_USERNAME, MQTT_PASSWORD)) {
            Serial.println("Connected to MQTT Broker.");
            subscribeToTopics();
        } else {
            Serial.print("Failed to connect, rc=");
            Serial.print(mqttClient.state());
            Serial.println(" retrying in 5 seconds");
            delay(5000);
        }
    }
}

void handleMQTT() {
    if (!mqttClient.connected()) {
        reconnectMQTT();
    }
    mqttClient.loop();
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
    // Convert payload to string
    String message;
    for (unsigned int i = 0; i < length; i++) {
        message += (char)payload[i];
    }
    
    String topicStr = String(topic);
    
    // Handle READ commands or periodic readings
    if (message.equals("READ") || topicStr.startsWith(PERIODIC_PREFIX)) {
        // Handle light sensor
        if (topicStr.endsWith(TOPIC_SUFFIX_PHOTOCELL)) {
            int lightLevel = readLightLemqttClient.publish(topicPublishLight.c_str(), String(lightLevel).c_str());vel();
            
        }
        // Handle temperature readings
        else if (topicStr.endsWith(TOPIC_SUFFIX_DHT11_TEMP)) {
            float tempF = readTemperature();
            char tempStr[8];
            dtostrf(tempF, 6, 2, tempStr);
            mqttClient.publish(topicPublishTemp.c_str(), tempStr);
        }
        // Handle humidity readings
        else if (topicStr.endsWith(TOPIC_SUFFIX_DHT11_HUMI)) {
            float humidity = readHumidity();
            char humiStr[8];
            dtostrf(humidity, 6, 2, humiStr);
            mqttClient.publish(topicPublishHumidity.c_str(), humiStr);
        }
        // Handle soil moisture readings
        else if (topicStr.endsWith(TOPIC_SUFFIX_SM_SENSOR)) {
            int soilMoisture = readSoilMoisture();
            mqttClient.publish(topicPublishSM.c_str(), String(soilMoisture).c_str());
        }
    }
} 