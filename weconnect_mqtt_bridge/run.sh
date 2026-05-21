#!/usr/bin/with-contenv bashio

set -euo pipefail

export HOME=/data
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

mkdir -p /data

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
PICTURE_FORMAT="$(bashio::config 'picture_format')"
LOCALE_VALUE="$(bashio::config 'locale')"
ADDITIONAL_ARGUMENTS="$(bashio::config 'additional_arguments')"
TIMEZONE_VALUE="$(bashio::timezone)"

cmd=(
  /opt/venv/bin/weconnect-mqtt
  --username "$USERNAME"
  --password "$PASSWORD"
  --mqttbroker "$MQTT_BROKER"
  --mqttport "$MQTT_PORT"
  --prefix "$MQTT_PREFIX"
  --interval "$UPDATE_INTERVAL"
  --mqttkeepalive "$MQTT_KEEPALIVE"
  --mqtt-version "$MQTT_VERSION"
  --transport "$TRANSPORT"
  --picture-format "$PICTURE_FORMAT"
  --logging-format "%(asctime)s:%(levelname)s:%(module)s:%(message)s"
  --logging-date-format "%Y-%m-%dT%H:%M:%S%z"
)

if bashio::config.true 'update_on_connect'; then
  cmd+=(--update-on-connect)
fi

if bashio::config.true 'republish_on_update'; then
  cmd+=(--republish-on-update)
fi

if bashio::config.true 'with_raw_json_topic'; then
  cmd+=(--with-raw-json-topic)
fi

if bashio::config.true 'list_topics'; then
  cmd+=(--list-topics)
fi

if bashio::config.true 'pictures'; then
  cmd+=(--pictures)
fi

if bashio::config.true 'no_capabilities'; then
  cmd+=(--no-capabilities)
fi

if bashio::config.true 'use_tls'; then
  cmd+=(--use-tls)
fi

if bashio::config.true 'insecure'; then
  cmd+=(--insecure)
fi

if bashio::config.true 'convert_times'; then
  cmd+=(--convert-times "$TIMEZONE_VALUE")
fi

if [[ -n "$SPIN" ]]; then
  cmd+=(--spin "$SPIN")
fi

if [[ -n "$MQTT_USERNAME" ]]; then
  cmd+=(--mqtt-username "$MQTT_USERNAME")
fi

if [[ -n "$MQTT_PASSWORD" ]]; then
  cmd+=(--mqtt-password "$MQTT_PASSWORD")
fi

if [[ -n "$LOCALE_VALUE" ]]; then
  cmd+=(--locale "$LOCALE_VALUE")
fi

if [[ -n "$ADDITIONAL_ARGUMENTS" ]]; then
  read -r -a user_extra <<< "$ADDITIONAL_ARGUMENTS"
  cmd+=("${user_extra[@]}")
fi

bashio::log.info "Starting WeConnect MQTT Bridge"
bashio::log.info "MQTT broker: ${MQTT_BROKER}:${MQTT_PORT}"
bashio::log.info "MQTT prefix: ${MQTT_PREFIX}"
bashio::log.info "Interval: ${UPDATE_INTERVAL}s"

exec "${cmd[@]}"
