FROM docker.io/alpine:edge AS base

RUN set -ex && \
    apk update && \
    apk add --no-cache --upgrade \
        jq \
        libcurl \
        libintl \
        libgcc \
        libssl3 \
        libstdc++ \
        tzdata

FROM base AS builder

ARG BTAG=4.0.0

RUN set -ex && \
    apk add --no-cache --upgrade \
      git \
      python3 \
      build-base \
      cmake \
      curl-dev \
      gettext-dev \
      openssl-dev \
      linux-headers \
      samurai

WORKDIR /usr/src
RUN git config --global advice.detachedHead false; \
    git clone https://github.com/transmission/transmission transmission --branch ${BTAG} --single-branch

WORKDIR /usr/src/transmission
RUN git submodule update --init --recursive; \
    cmake \
      -S . \
      -B obj \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DENABLE_CLI=OFF \
      -DENABLE_DAEMON=ON \
      -DENABLE_GTK=OFF \
      -DENABLE_MAC=OFF \
      -DENABLE_QT=OFF \
      -DENABLE_TESTS=OFF \
      -DENABLE_UTILS=OFF \
      -DENABLE_WEB=OFF \
      -DRUN_CLANG_TIDY=OFF \
      -DWITH_CRYPTO="openssl" \
      -DWITH_SYSTEMD=OFF && \
    cmake --build obj --config Release; \
    cmake --build obj --config Release --target install/strip

FROM base AS runtime

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/share /usr/local/share
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