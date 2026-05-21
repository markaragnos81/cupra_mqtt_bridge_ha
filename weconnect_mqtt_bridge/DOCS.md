# WeConnect MQTT Bridge

Dieses Add-on startet [`weconnect-mqtt`](https://github.com/tillsteinbach/WeConnect-mqtt) direkt in Home Assistant und publiziert die Fahrzeugdaten in deinen MQTT-Broker.

## Was das Add-on macht

- Login bei Volkswagen/WeConnect mit deinen Zugangsdaten
- Regelmaessiges Abrufen der Fahrzeugdaten
- Publizieren aller verfuegbaren Werte nach MQTT
- Optional: Publizieren eines `rawjson`-Topics fuer eigene Weiterverarbeitung

## Wichtiger Hinweis zu Cupra

`WeConnect-mqtt` ist upstream im End-of-Life-Uebergang. Der Maintainer verweist fuer Seat/Cupra/Skoda langfristig auf `CarConnectivity-plugin-mqtt`.

Das Add-on hier kapselt bewusst trotzdem `WeConnect-mqtt`, weil du genau diese Basis angefragt hast. Fuer neuere Cupra-Modelle kann es sein, dass spaeter ein Wechsel auf CarConnectivity noetig wird.

## Konfiguration

Minimal noetig:

- `username`: Volkswagen/Cupra Login
- `password`: Passwort
- `mqtt_broker`: Hostname oder IP deines MQTT-Brokers

Empfohlene Defaults:

- `mqtt_broker`: `core-mosquitto` wenn du das offizielle Mosquitto-Add-on nutzt
- `mqtt_prefix`: `weconnect/0`
- `with_raw_json_topic`: `true`
- `convert_times`: `true`
- `locale`: leer lassen oder gezielt `de_DE.UTF-8` setzen

## Installation

1. Dieses Repository als Add-on-Repository in Home Assistant hinzufuegen.
2. Das Add-on `WeConnect MQTT Bridge` installieren.
3. Konfiguration eintragen.
4. Add-on starten.
5. Im MQTT-Broker pruefen, ob Topics unter `weconnect/0/...` erscheinen.

## Beispielkonfiguration

```yaml
username: "name@example.com"
password: "supersecret"
spin: ""
mqtt_broker: "core-mosquitto"
mqtt_port: 1883
mqtt_username: ""
mqtt_password: ""
mqtt_prefix: "weconnect/0"
update_interval: 300
mqtt_keepalive: 60
mqtt_version: "3.1.1"
transport: "tcp"
use_tls: false
insecure: false
pictures: false
picture_format: "txt"
no_capabilities: false
update_on_connect: true
republish_on_update: false
with_raw_json_topic: true
list_topics: false
convert_times: true
locale: ""
additional_arguments: ""
```

## Eigene Home-Assistant-Sensoren

`weconnect-mqtt` publiziert Werte nach MQTT, aber keine nativen Home-Assistant-Discovery-Entitaeten. Die Werte kannst du daher entweder:

- mit MQTT Discovery eines vorgeschalteten Mappers nutzen
- oder direkt als MQTT-Sensoren in Home Assistant anlegen

Beispiel:

```yaml
mqtt:
  sensor:
    - name: "Cupra Battery Level"
      state_topic: "weconnect/0/vehicles/WVWZZZ.../domains/charging/batteryStatus/currentSOC_pct"
      unit_of_measurement: "%"
    - name: "Cupra Range"
      state_topic: "weconnect/0/vehicles/WVWZZZ.../domains/measurements/range/cruisingRangeElectric_km"
      unit_of_measurement: "km"
```

## Erweiterte Optionen

Mit `additional_arguments` kannst du zusaetzliche `weconnect-mqtt` CLI-Parameter durchreichen, zum Beispiel:

```text
--selective climatisation --selective charging
```
