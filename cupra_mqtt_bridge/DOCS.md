# Cupra MQTT Bridge

Dieses Add-on startet [`CarConnectivity-plugin-mqtt`](https://github.com/tillsteinbach/CarConnectivity-plugin-mqtt) zusammen mit dem Connector [`carconnectivity-connector-seatcupra`](https://github.com/tillsteinbach/CarConnectivity-connector-seatcupra) direkt in Home Assistant und publiziert die Fahrzeugdaten in deinen MQTT-Broker.

## Was das Add-on macht

- Login bei MyCupra oder MySeat mit deinen Zugangsdaten
- Regelmaessiges Abrufen der Fahrzeugdaten
- Publizieren aller verfuegbaren Werte nach MQTT
- Optional: Home-Assistant MQTT Discovery ueber `mqtt_homeassistant`
- Optional: Publizieren eines `full_json`-Topics fuer eigene Weiterverarbeitung

## Basis

Dieses Add-on basiert jetzt auf dem neueren CarConnectivity-Stack, der laut Upstream der Nachfolger des alten WeConnect-Wegs fuer mehrere Marken ist, darunter Seat und Cupra.

## Konfiguration

Minimal noetig:

- `brand`: `cupra` oder `seat`
- `username`: MyCupra/MySeat Login
- `password`: Passwort
- `mqtt_broker`: Hostname oder IP deines MQTT-Brokers

Empfohlene Defaults:

- `mqtt_broker`: `core-mosquitto` wenn du das offizielle Mosquitto-Add-on nutzt
- `mqtt_prefix`: `carconnectivity/0`
- `enable_homeassistant_discovery`: `true`
- `with_full_json`: `true`
- `convert_times`: `true`
- `locale`: leer lassen oder gezielt `de_DE.UTF-8` setzen

## Installation

1. Dieses Repository als Add-on-Repository in Home Assistant hinzufuegen.
2. Das Add-on `Cupra MQTT Bridge` installieren.
3. Konfiguration eintragen.
4. Add-on starten.
5. Im MQTT-Broker pruefen, ob Topics unter `carconnectivity/0/...` erscheinen.

## Beispielkonfiguration

```yaml
brand: "cupra"
username: "name@example.com"
password: "supersecret"
spin: ""
mqtt_broker: "core-mosquitto"
mqtt_port: 1883
mqtt_username: ""
mqtt_password: ""
mqtt_prefix: "carconnectivity/0"
update_interval: 300
mqtt_keepalive: 60
mqtt_version: "3.1.1"
transport: "tcp"
mqtt_client_id: ""
use_tls: false
insecure: false
picture_format: "png"
republish_on_update: false
retain_on_disconnect: true
with_full_json: true
convert_times: true
enable_homeassistant_discovery: true
log_level: "error"
api_log_level: "error"
max_age: 300
locale: ""
hide_vins: ""
```

## Home Assistant

Wenn `enable_homeassistant_discovery` aktiv ist, bindet Home Assistant viele Entitaeten direkt ueber MQTT Discovery ein.

Falls du einzelne Topics manuell anbinden willst, geht das weiterhin ueber MQTT-Sensoren.

Beispiel:

```yaml
mqtt:
  sensor:
    - name: "Cupra Battery Level"
      state_topic: "carconnectivity/0/garage/WVWZZZ.../drives/electric/range/level/value"
      unit_of_measurement: "%"
    - name: "Cupra Range"
      state_topic: "carconnectivity/0/garage/WVWZZZ.../drives/electric/range/value"
      unit_of_measurement: "km"
```

## Erweiterte Optionen

- `hide_vins`: Kommagetrennte Liste von VINs, die ignoriert werden sollen
- `picture_format`: `png` oder `txt`
- `api_log_level`: Detailgrad des Seat/Cupra-Connectors

## Bilder

Die benoetigten Python-Bibliotheken fuer Fahrzeugbilder sind im Add-on enthalten.

- `picture_format: png` publiziert PNG-Bilder
- `picture_format: txt` publiziert ASCII-Bilder
