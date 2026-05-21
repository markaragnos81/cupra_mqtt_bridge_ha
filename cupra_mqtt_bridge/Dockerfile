FROM ghcr.io/home-assistant/base:latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
  apk add --no-cache \
    bash \
    build-base \
    freetype-dev \
    jpeg-dev \
    lcms2-dev \
    musl-locales \
    musl-locales-lang \
    openjpeg-dev \
    py3-pip \
    python3 \
    tcl-dev \
    tiff-dev \
    tk-dev \
    zlib-dev \
  && python3 -m venv /opt/venv \
  && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
  && /opt/venv/bin/pip install --no-cache-dir \
    carconnectivity-plugin-mqtt \
    carconnectivity-connector-seatcupra \
    carconnectivity-plugin-mqtt_homeassistant \
  && apk del build-base

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
