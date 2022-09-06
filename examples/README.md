## Install as Systemd Service

- Create directory /opt/theengsgateway
- Copy docker-compose.yml from this directory to /opt/theengsgateway
- Make nececarry changes to docker-compose.yml, make sure `image` matches the architecture where you want to install TheengsGateway
- Copy theengsgateway.service from this directory to /etc/systemd/system/theengsgateway.service
- Make changes to WorkingDirectory in theengsgateway.service if you haven't copied docker-compose.yml to /opt/theengsgateway, use other directory instead
- Run `systemctl daemon-reload`
- Run systemctl start theengsgateway to start the service
- Run journalctl -xefu theengsgateway to tail logs
- Run journalctl -xeu theengsgateway to view snapshot of logs
- Run systemctl stop theengsgateway to stop the service
- Run systemctl status theengsgateway to check the status of a service

## Install as Systemd Service on LibreElec
- Create directory /storage/.kodi/userdata/custom/dockerfiles/theengsgateway
- Copy docker-compose.yml from this directory to /storage/.kodi/userdata/custom/dockerfiles/theengsgateway
- Make nececarry changes to docker-compose.yml, make sure `image` matches the architecture where you want to install TheengsGateway
- Copy theengsgateway.service from this directory to /storage/.config/system.d/theengsgateway.service
- Make changes to WorkingDirectory in theengsgateway.service to point to /storage/.config/system.d/theengsgateway.service
- Run `systemctl daemon-reload`
- Run systemctl start theengsgateway to start the service
- Run journalctl -xefu theengsgateway to tail logs
- Run journalctl -xeu theengsgateway to view snapshot of logs
- Run systemctl stop theengsgateway to stop the service
- Run systemctl status theengsgateway to check the status of a service

