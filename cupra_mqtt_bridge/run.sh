#!/usr/bin/with-contenv bashio

set -euo pipefail

export HOME=/data
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

mkdir -p /data

BRAND="$(bashio::config 'brand')"
USERNAME="$(bashio::config 'username')"
PASSWORD="$(bashio::config 'password')"
SPIN="$(bashio::config 'spin')"
MQTT_BROKER="$(bashio::config 'mqtt_broker')"
MQTT_PORT="$(bashio::config 'mqtt_port')"
MQTT_USERNAME="$(bashio::config 'mqtt_username')"
MQTT_PASSWORD="$(bashio::config 'mqtt_password')"
MQTT_PREFIX="$(bashio::config 'mqtt_prefix')"
UPDATE_INTERVAL="$(bashio::config 'update_interval')"
MQTT_KEEPALIVE="$(bashio::config 'mqtt_keepalive')"
MQTT_VERSION="$(bashio::config 'mqtt_version')"
TRANSPORT="$(bashio::config 'transport')"
MQTT_CLIENT_ID="$(bashio::config 'mqtt_client_id')"
PICTURE_FORMAT="$(bashio::config 'picture_format')"
LOG_LEVEL="$(bashio::config 'log_level')"
API_LOG_LEVEL="$(bashio::config 'api_log_level')"
MAX_AGE="$(bashio::config 'max_age')"
LOCALE_VALUE="$(bashio::config 'locale')"
HIDE_VINS="$(bashio::config 'hide_vins')"
TIMEZONE_VALUE="$(bashio::timezone)"
CONFIG_PATH=/data/carconnectivity.json

export CONFIG_PATH
export BRAND
export USERNAME
export PASSWORD
export SPIN
export MQTT_BROKER
export MQTT_PORT
export MQTT_USERNAME
export MQTT_PASSWORD
export MQTT_PREFIX
export UPDATE_INTERVAL
export MQTT_KEEPALIVE
export MQTT_VERSION
export TRANSPORT
export MQTT_CLIENT_ID
export PICTURE_FORMAT
export LOG_LEVEL
export API_LOG_LEVEL
export MAX_AGE
export LOCALE_VALUE
export HIDE_VINS
export TIMEZONE_VALUE
export USE_TLS=false
export TLS_INSECURE=false
export REPUBLISH_ON_UPDATE=false
export RETAIN_ON_DISCONNECT=false
export WITH_FULL_JSON=false
export CONVERT_TIMES=false
export ENABLE_HOMEASSISTANT_DISCOVERY=false

if bashio::config.true 'use_tls'; then export USE_TLS=true; fi
if bashio::config.true 'insecure'; then export TLS_INSECURE=true; fi
if bashio::config.true 'republish_on_update'; then export REPUBLISH_ON_UPDATE=true; fi
if bashio::config.true 'retain_on_disconnect'; then export RETAIN_ON_DISCONNECT=true; fi
if bashio::config.true 'with_full_json'; then export WITH_FULL_JSON=true; fi
if bashio::config.true 'convert_times'; then export CONVERT_TIMES=true; fi
if bashio::config.true 'enable_homeassistant_discovery'; then export ENABLE_HOMEASSISTANT_DISCOVERY=true; fi

/opt/venv/bin/python - <<'PY'
import json
import os

hide_vins_raw = os.environ.get("HIDE_VINS", "").strip()
hide_vins = [vin.strip() for vin in hide_vins_raw.split(",") if vin.strip()]

connector_config = {
    "interval": int(os.environ["UPDATE_INTERVAL"]),
    "brand": os.environ["BRAND"],
    "username": os.environ["USERNAME"],
    "password": os.environ["PASSWORD"],
    "max_age": int(os.environ["MAX_AGE"]),
    "api_log_level": os.environ["API_LOG_LEVEL"],
}
if os.environ.get("SPIN"):
    connector_config["spin"] = os.environ["SPIN"]
if hide_vins:
    connector_config["hide_vins"] = hide_vins

mqtt_config = {
    "broker": os.environ["MQTT_BROKER"],
    "port": int(os.environ["MQTT_PORT"]),
    "prefix": os.environ["MQTT_PREFIX"],
    "keepalive": int(os.environ["MQTT_KEEPALIVE"]),
    "version": os.environ["MQTT_VERSION"],
    "transport": os.environ["TRANSPORT"],
    "tls": os.environ["USE_TLS"].lower() == "true",
    "tls_insecure": os.environ["TLS_INSECURE"].lower() == "true",
    "republish_on_update": os.environ["REPUBLISH_ON_UPDATE"].lower() == "true",
    "retain_on_disconnect": os.environ["RETAIN_ON_DISCONNECT"].lower() == "true",
    "with_full_json": os.environ["WITH_FULL_JSON"].lower() == "true",
    "image_format": os.environ["PICTURE_FORMAT"],
}
if os.environ.get("MQTT_USERNAME"):
    mqtt_config["username"] = os.environ["MQTT_USERNAME"]
if os.environ.get("MQTT_PASSWORD"):
    mqtt_config["password"] = os.environ["MQTT_PASSWORD"]
if os.environ.get("MQTT_CLIENT_ID"):
    mqtt_config["clientid"] = os.environ["MQTT_CLIENT_ID"]
if os.environ.get("LOCALE_VALUE"):
    mqtt_config["locale"] = os.environ["LOCALE_VALUE"]
if os.environ.get("CONVERT_TIMES", "").lower() == "true":
    mqtt_config["convert_timezone"] = os.environ["TIMEZONE_VALUE"]

plugins = [{"type": "mqtt", "config": mqtt_config}]
if os.environ.get("ENABLE_HOMEASSISTANT_DISCOVERY", "").lower() == "true":
    plugins.append({"type": "mqtt_homeassistant", "config": {}})

config = {
    "carConnectivity": {
        "log_level": os.environ["LOG_LEVEL"],
        "connectors": [
            {"type": "seatcupra", "config": connector_config}
        ],
        "plugins": plugins,
    }
}

with open(os.environ["CONFIG_PATH"], "w", encoding="utf-8") as file_handle:
    json.dump(config, file_handle, indent=2)
PY

bashio::log.info "Starting Cupra MQTT Bridge"
bashio::log.info "MQTT broker: ${MQTT_BROKER}:${MQTT_PORT}"
bashio::log.info "MQTT prefix: ${MQTT_PREFIX}"
bashio::log.info "Brand: ${BRAND}"
bashio::log.info "Interval: ${UPDATE_INTERVAL}s"

exec /opt/venv/bin/carconnectivity-mqtt "${CONFIG_PATH}"
