#!/bin/bash

CONFIG="$HOME/theengsgw.conf"

isempty() {
        if [ x"$1" == "x" ]; then
                return 0
        else
                return 1
        fi
}

# Exit if MQTT host not specified
if isempty $MQTT_HOST; then
        echo "MQTT Host not defined, exiting"
        exit 1
fi

# If we enter username...
if ! isempty $MQTT_USERNAME; then
	# ...we must check for password too
        if isempty $MQTT_PASSWORD; then
                echo "MQTT_USERNAME specified without MQTT_PASSWORD"
                exit 1
        fi
fi

if ! isempty $PASSIVE_SCAN and [[ $PASSIVE_SCAN == true ]]; then
	echo "Passive mode not yet implemented"
	#echo "Enabling passive scanning mode"
	#PARAMS="$PARAMS --scanning_mode passive"
fi

cd $VIRTUAL_ENV

echo "Creating config at $CONFIG ..."
cat <<EOF> $CONFIG
{
    "host": "$MQTT_HOST",
    "pass": "$MQTT_PASSWORD",
    "user": "$MQTT_USERNAME",
    "port": ${MQTT_PORT:-1883},
    "publish_topic": "${MQTT_PUB_TOPIC:-home/TheengsGateway/BTtoMQTT}",
    "subscribe_topic": "${MQTT_SUB_TOPIC:-home/TheengsGateway/commands}",
    "publish_all": ${PUBLISH_ALL:-true},
    "ble_scan_time": ${SCAN_TIME:-60},
    "ble_time_between_scans": ${TIME_BETWEEN:-60},
    "log_level": "${LOG_LEVEL:-DEBUG}",
    "discovery": ${DISCOVERY:-true},
    "discovery_topic": "${DISCOVERY_TOPIC:-homeassistant/sensor}",
    "discovery_device_name": "${DISCOVERY_DEVICE_NAME:-TheengsGateway}",
    "discovery_filter": "${DISCOVERY_FILTER:-[IBEACON,GAEN,MS-CDP]}",
    "adapter": "${ADAPTER:-hci0}"
}
EOF
cat $CONFIG

python3 -m TheengsGateway $PARAMS
