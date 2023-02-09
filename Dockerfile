FROM docker.io/debian:stable-slim AS base

RUN set -ex; \
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get install -y --no-install-recommends \
      tzdata \
      iproute2 \
      net-tools \
      nano \
      ca-certificates \
      curl \
      libcurl4-openssl-dev \
      libdeflate-dev \
      libevent-dev \
      libfmt-dev \
      libminiupnpc-dev \
      libnatpmp-dev \
      libpsl-dev \
      libssl-dev \
      jq

FROM base AS builder

ARG BTAG=4.0.0

RUN set -ex; \
    apt-get install -y --no-install-recommends \
      git \
      cmake \
      g++ \
      gettext \
      ninja-build \
      pkg-config \
      xz-utils

WORKDIR /usr/src
RUN git config --global advice.detachedHead false; \
    git clone https://github.com/transmission/transmission transmission --branch ${BTAG} --single-branch

WORKDIR /usr/src/transmission
RUN git submodule update --init --recursive; \
    cmake \
      -S . \
      -B obj \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DENABLE_CLI=ON \
      -DENABLE_DAEMON=ON \
      -DENABLE_GTK=OFF \
      -DENABLE_MAC=OFF \
      -DENABLE_QT=OFF \
      -DENABLE_TESTS=OFF \
      -DENABLE_UTILS=ON \
      -DENABLE_WEB=OFF \
      -DRUN_CLANG_TIDY=OFF; \
    cmake --build obj --config RelWithDebInfo; \
    cmake --build obj --config RelWithDebInfo --target install/strip

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
ENV UMASK=
ENV TZ=America/Chicago

EXPOSE 9091/tcp 51413/tcp 51413/udp
VOLUME /config /watch /download

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]