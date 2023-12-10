FROM python:3.10-slim-bullseye

SHELL ["/bin/bash", "-ec"]

RUN apt update && apt install --no-install-recommends -y bluez build-essential
RUN python3 -m venv /opt/venv && \
        source /opt/venv/bin/activate && \
	pip install --upgrade --extra-index-url=https://www.piwheels.org/simple pip TheengsGateway==1.2.0

COPY chroot /
CMD source /opt/venv/bin/activate && exec /opt/venv/start.sh
