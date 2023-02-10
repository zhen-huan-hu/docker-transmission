FROM docker.io/alpine:edge

RUN set -ex && \
    apk update && \
    apk add --no-cache --upgrade transmission-daemon jq

COPY ./entrypoint.sh /usr/local/bin
COPY ./settings.json /defaults/settings.json

RUN set -ex && \
    chmod 755 /usr/local/bin/entrypoint.sh && \
    chmod 644 /defaults/settings.json

ENV RPC_USER=
ENV RPC_PASSWORD=
ENV RPC_WHITELIST=
ENV UMASK=
ENV TZ=America/Chicago

EXPOSE 9091/tcp 51413/tcp 51413/udp
VOLUME /config /watch /download

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]