# Theengs Gateway - Docker Version

|        Arch       |           Docker Image            |
| ----------------- | --------------------------------- |
| ![aarch64-shield] | maretodoric/theengsgateway-arm64  |
|  ![amd64-shield]  | maretodoric/theengsgateway-amd64  |
|  ![armv6-shield]  | maretodoric/theengsgateway-arm-v6 |
|  ![armv7-shield]  | maretodoric/theengsgateway-arm-v7 |
|  ![i386-shield]   | maretodoric/theengsgateway-i386   |

## Info (from their site - https://gateway.theengs.io/)

**Theengs Gateway** is a multi platforms, multi devices BLE to MQTT gateway that leverages the [Theengs Decoder library](https://github.com/theengs/decoder).
It retrieves data from a wide range of [BLE sensors](https://gateway.theengs.io/prerequisites/devices); LYWSD03MMC, CGD1, CGP1W, H5072, H5075, H5102, TH1, TH2, BBQ, CGH1, CGDK2, CGPR1, RuuviTag, WS02, WS08, TPMS, MiScale, LYWSD02, LYWSDCGQ, MiFlora... translates this information into a readable JSON format and pushes those to an MQTT broker.

Enabling integration to IOT platforms or home automation controllers like [NodeRED](https://nodered.org/), [AWS IOT](https://aws.amazon.com/iot/), [Home Assistant](https://www.home-assistant.io/), [OpenHAB](https://www.openhab.org/), [FHEM](https://fhem.de/), [IOBroker](https://www.iobroker.net/) or [DomoticZ](https://domoticz.com/).

The gateway uses the bluetooth component of your Raspberry Pi, Windows, Apple desktop, laptop or server by leveraging python and multi platform libraries.

**Theengs Gateway** can be used as a standalone solution or as a complementary solution to [OpenMQTTGateway](https://docs.openmqttgateway.com/) as it uses the same MQTT topic structure and the same payload messages. Your OpenMQTTGateway Home Automation BLE sensors integration will work also with Theengs gateway.

The gateway will retrieve data from BLE sensors from Govee, Xiaomi, Inkbird, QingPing, ThermoBeacon, ClearGrass, Blue Maestro and many more.

## Install Theengs Gateway
Doing so is simple as 1 command:
```shell
pip3 install TheengsGateway
```

You can access advanced configuration by typing:
```shell
python3 -m TheengsGateway -h
```

## Install Theengs Gateway as an Add ON in Home Assistant
1. Open Home Assistant and navigate to the "Add-on Store". Click on the 3 dots (top right) and select "Repositories".
2. Enter `https://github.com/mihsu81/addon-theengsgw` in the box and click on "Add".
3. You should now see "TheengsGateway HA Add-on" at the bottom list.
4. Click on "TheengsGateway", then click "Install".
5. Under the "Configuration" tab, change the settings appropriately (at least MQTT parameters), see [Parameters](#parameters).
6. Start the Add-on.

## Install Theengs Gateway as a snap
Theengs Gateway is also packaged as a snap in the [Snap Store](https://snapcraft.io/theengs-gateway). If you have snapd running on your Linux distribution, which is the case by default on Ubuntu, you can install the Theengs Gateway snap as:

```shell
snap install theengs-gateway
```

Have a look at the [Theengs Gateway Snap](https://github.com/theengs/gateway-snap) documentation for more information about how to configure and start Theengs Gateway as a service.

## So why the Docker Version?
It happened just so that in my home, somehow Raspberry Pi 3 (where my Home Assistance Instance is hosted) Integrated Bluetooth adapter died and all my BLE sensors are now unavailable. Theengs Gateway seemed like a perfect thing to install on my Raspberry Pi 4 which is used as a media server.
However, this is where the problem happened.
I have LibreElec installed on RPi 4, therefore i could not use any of methods above to install Theengs Gateway, because:
- pip was not installed, installing it on LibreElec would not keep it there since it uses overlay image. On next boot it would be overwritten
- snap is not part of LibreElec and could not be installed
- I want to keep RPi 4 as a media server, so overwriting it with Home Assistant installation is not an option

## Birth of Docker Version
LibreElec natively comes with Docker. So building a docker image and running it inside LibreElec is a great way to run Theengs Gateway there.
Also, this may help other users who prefer to use Docker to install Theengs Gateway.

## Usage
Here are two ways to run Theengs Gateway in Docker.

### docker-compose.yml
You can write a docker-compose.yml and use docker compose plugin to run. This is a preferred method as it's more humanly readable. Following docker-compose.yml can be used:
```
# docker-compose.yml
version: '3.1'

services:
  theengsgateway:
    image: maretodoric/theengsgateway-ARCH:latest
    network_mode: host
    environment:
      MQTT_HOST: <host_ip>
      MQTT_USERNAME: <username>
      MQTT_PASSWORD: <password>
      MQTT_PUB_TOPIC: home/TheengsGateway/BTtoMQTT
      MQTT_SUB_TOPIC: home/TheengsGateway/commands
      PUBLISH_ALL: true
      TIME_BETWEEN: 60
      SCAN_TIME: 60
      LOG_LEVEL: DEBUG
      DISCOVERY_TOPIC: homeassistant/sensor
      DISCOVERY_DEVICE_NAME: TheengsGateway
      DISCOVERY_FILTER: "[IBEACON,GAEN,MS-CDP]"
      SCANNING_MODE: active
      ADAPTER: hci0
    volumes:
      - /var/run/dbus:/var/run/dbus
```

*MQTT_HOST* is mandatory field, ofcourse.
*MQTT_USERNAME* and *MQTT_PASSWORD* you use if you require authentication with MQTT Host.

Other variables are not mandatory and you can even leave them out, default values will be used, so you can shorten your docker-compose.yml to this one (if username/password is not used):

```
# docker-compose.yml
version: '3.1'

services:
  theengsgateway:
    image: maretodoric/theengsgateway-ARCH:latest
    network_mode: host
    environment:
      MQTT_HOST: <host_ip>
    volumes:
      - /var/run/dbus:/var/run/dbus
```

After you have the file created, run `docker-compose up` or `docker compose up`. It will start the process where you can monitor the progress.
This is not ideal way to run but great for first run and for testing to see what's going on and for checking messages.
If you wish to run in background, append --detach after "up" command.

To bring it down, use `docker-compose down; docker-compose rm -f` or `docker compose down; docker compose rm -f`.

All of these docker compose commands need to be ran from same directory as where docker-compose.yml file is created.

### Using docker run command
You can use following command to run if you don't have docker compose plugin installed:
```
docker run --rm \
    --network host \
    -e MQTT_HOST=<host_ip> \
    -e MQTT_USERNAME=<username> \
    -e MQTT_PASSWORD=<password> \
    -e MQTT_PUB_TOPIC=home/TheengsGateway/BTtoMQTT \
    -e MQTT_SUB_TOPIC=home/TheengsGateway/commands \
    -e PUBLISH_ALL=true \
    -e TIME_BETWEEN=60 \
    -e SCAN_TIME=60 \
    -e LOG_LEVEL=DEBUG \
    -e DISCOVERY_TOPIC=homeassistant/sensor \
    -e DISCOVERY_DEVICE_NAME=TheengsGateway \
    -e DISCOVERY_FILTER="[IBEACON,GAEN,MS-CDP]" \
    -e SCANNING_MODE=active
    -e ADAPTER=hci0 \
    -v /var/run/dbus:/var/run/dbus \
    --name theengsgateway \
    maretodoric/theengsgateway-ARCH:latest
```

And again, shorten it like this if you wish to use recommended defaults (without user/pass):

```
docker run --rm \
    --network host \
    -e MQTT_HOST=<host_ip> \
    -v /var/run/dbus:/var/run/dbus \
    --name theengsgateway \
    maretodoric/theengsgateway-ARCH:latest
```

These commands will run the container in foreground, it's not ideal, but if you wish to see what's happening it's great - for testing.
If you want to run it in background, add "--detach" between *docker run* and *--rm*

## Configuration

Once again, MQTT_HOST is the *ONLY* required option, all others can be ommited and defaults will be used.
If used without MQTT_USERNAME and MQTT_PASSWORD, it will try to login annonymously, otherwise, please provide MQTT_USERNAME and MQTT_PASSWORD too.

As for other configuration options for Theengs Gateway, please review any and all on [Details options](https://gateway.theengs.io/use/use.html#details-options) page on Theengs Gateway official site.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv6-shield]: https://img.shields.io/badge/armv6-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
