FROM debian:stable-slim

ARG APPLICATION="autossh-deb"
ARG BUILD_RFC3339="2024-09-28T22:34:03+00:00Z"
ARG DESCRIPTION="autossh tunnel on debian"
ARG PACKAGE="deepak/autossh-deb"

ENV \
  APPLICATION="${APPLICATION}" \
  BUILD_RFC3339="${BUILD_RFC3339}" \
  DESCRIPTION="${DESCRIPTION}" \
  PACKAGE="${PACKAGE}"

LABEL org.opencontainers.image.ref.name="${PACKAGE}" \
  org.opencontainers.image.created=$BUILD_RFC3339 \
  org.opencontainers.image.authors="Justin J. Novack <jnovack@gmail.com>" \
  org.opencontainers.image.documentation="https://github.com/${PACKAGE}/README.md" \
  org.opencontainers.image.description="${DESCRIPTION}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.source="https://github.com/${PACKAGE}" \
  org.opencontainers.image.revision=$REVISION \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.url="https://hub.docker.com/r/${PACKAGE}/"

ARG REVISION="r1"
ARG VERSION="2.0.0"

ENV \
  REVISION="${REVISION}" \
  VERSION="${VERSION}"

LABEL org.opencontainers.image.revision=$REVISION \
  org.opencontainers.image.version=$VERSION

RUN apt-get update && apt-get install -y \
    autossh dumb-init \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --home-dir /home/user --shell /bin/bash user
USER user
WORKDIR /home/user
RUN mkdir .ssh && chmod 700 .ssh

ENV \
  AUTOSSH_PIDFILE=/tmp/autossh.pid \
  AUTOSSH_POLL=30 \
  AUTOSSH_GATETIME=30 \
  AUTOSSH_FIRST_POLL=30 \
  AUTOSSH_LOGLEVEL=0 \
  AUTOSSH_LOGFILE=/dev/stdout

COPY --chown=user:user ./rootfs/version.sh ./version.sh
COPY --chown=user:user ./rootfs/entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["entrypoint.sh"]
