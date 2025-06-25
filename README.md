# 🌱 Plant Pulse  
_Full-stack IoT plant-health platform_

PlantPulse is a real-time dashboard built with Phoenix LiveView and powered by sensor data collected from an ESP32 microcontroller.
It measures light, temperature, humidity and soil-moisture every hour, pushes the readings over MQTT, stores them in Postgres and surfaces a responsive UI with live thresholds.

---

## 🧰 Tech Stack

- **Elixir 1.14** – functional language for scalable, fault-tolerant systems  
- **Phoenix 1.7** + **LiveView 0.20** – real-time web UI with zero client-side JS  
- **PostgreSQL** – robust relational database, integrated via **Ecto**  
- **MQTT** (`tortoise311`) over TLS – lightweight messaging protocol for IoT data  
- **Tailwind CSS** + **Heroicons** – modern UI styling and accessible iconography  
- **ESP32** + **PlatformIO (C++)** – microcontroller firmware for sensor readings  


---

## Architecture (high level)

```text
┌────────────-┐    Wi-Fi + MQTT/TLS     ┌───────────────────────┐
│ ESP32 Node  │ ───────────────────────▶│ Phoenix MQTT Client   │
│  • DHT11    │                         │  (Tortoise311)        │
│  • Photocell│                         └--──────-─┬────────────┘
│  • Soil M.  │                   broadcast to LV  │
└────────────-┘                                    ▼
                                       ┌───────────────────────┐
                                       │ LiveView Dashboard    │
                                       │  • Charts & thresholds│
                                       └──────────-┬───────────┘
                                                   |
                                                   ▼
                                       ┌───────────────────────┐
                                       │ Postgres via Ecto     │
                                       └───────────────────────┘

```

