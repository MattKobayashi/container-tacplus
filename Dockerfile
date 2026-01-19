FROM debian:trixie-slim@sha256:77ba0164de17b88dd0bf6cdc8f65569e6e5fa6cd256562998b62553134a00ef0 AS build

WORKDIR /opt/event-driven-servers

# Dependencies
RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
      build-essential \
      ca-certificates \
      curl \
      libpcre2-dev

# Build
RUN curl -fsSLo event-driven-servers.tar.gz https://github.com/MarcJHuber/event-driven-servers/archive/29eeb73042a468e476af72248440dff9a66bbf43.tar.gz \
    && tar --strip-components=1 -xf event-driven-servers.tar.gz \
    && ./configure --minimum tac_plus-ng \
    && make \
    && make install

FROM debian:trixie-slim@sha256:77ba0164de17b88dd0bf6cdc8f65569e6e5fa6cd256562998b62553134a00ef0

# Environment variables
ENV TACPLUS_CFG_FILE=/opt/tac_plus-ng.cfg

# Copy build files
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /usr/local/lib/ /usr/local/lib/
COPY --from=build /usr/local/sbin/ /usr/local/sbin/
COPY --chmod=755 <<'EOT' /entrypoint.sh
#!/usr/bin/env bash
set -e
/usr/local/sbin/tac_plus-ng -f $TACPLUS_CFG_FILE
EOT

# Set expose ports and entrypoint
EXPOSE 49/tcp
ENTRYPOINT ["/entrypoint.sh"]

LABEL org.opencontainers.image.authors="MattKobayashi <matthew@kobayashi.au>"
