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

FROM debian:trixie-slim@sha256:77ba0164de17b88dd0bf6cdc8f65569e6e5fa6cd256562998b62553134a00ef0 AS s6overlay

# Dependencies
RUN apt-get update \
    && apt-get --no-install-recommends --yes install \
    ca-certificates \
    curl \
    xz-utils

# s6-overlay
# renovate: datasource=github-releases packageName=just-containers/s6-overlay versioning=loose
ARG S6_OVERLAY_VERSION="v3.2.1.0"
WORKDIR /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz.sha256 /tmp
RUN echo "$(cat s6-overlay-noarch.tar.xz.sha256)" | sha256sum -c - \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz.sha256 /tmp
RUN echo "$(cat s6-overlay-x86_64.tar.xz.sha256)" | sha256sum -c - \
    && tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
COPY s6-rc.d/ /etc/s6-overlay/s6-rc.d/

FROM debian:trixie-slim@sha256:77ba0164de17b88dd0bf6cdc8f65569e6e5fa6cd256562998b62553134a00ef0

# Environment variables
ENV TACPLUS_CFG_FILE=/opt/tac_plus-ng.cfg

# s6-overlay
COPY --from=s6overlay /init /
COPY --from=s6overlay /command/ /command/
COPY --from=s6overlay /package/ /package/
COPY --from=s6overlay /etc/s6-overlay/ /etc/s6-overlay/

# Copy build files
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /usr/local/lib/ /usr/local/lib/
COPY --from=build /usr/local/sbin/ /usr/local/sbin/

# Set expose ports and entrypoint
EXPOSE 49/tcp
ENTRYPOINT ["/init"]

LABEL org.opencontainers.image.authors="MattKobayashi <matthew@kobayashi.au>"
