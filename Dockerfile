FROM python:3.10-bullseye

SHELL ["/bin/bash", "-ec"]

RUN python3 -m venv /opt/venv && \
        source /opt/venv/bin/activate && \
        apt update && apt install --no-install-recommends -y bluez && \
	pip install --upgrade pip && \
        pip install --extra-index-url=https://www.piwheels.org/simple TheengsGateway

COPY chroot /

CMD source /opt/venv/bin/activate && exec /opt/venv/start.sh
