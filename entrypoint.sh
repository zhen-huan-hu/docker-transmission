#!/bin/sh

set -eu

mkdir -p /config/log

if [ ! -f /config/settings.json ]; then
    install -m 600 /defaults/settings.json /config/settings.json
fi

if [ -n "${RPC_USER}" ] && [ -n "${RPC_PASSWORD}" ]; then
    echo $(jq \
            --arg RPC_USER "${RPC_USER}" \
            --arg RPC_PASSWORD "${RPC_PASSWORD}" \
            '."rpc-authentication-required" = true | ."rpc-username" = $RPC_USER | ."rpc-password" = $RPC_PASSWORD' \
            /config/settings.json
        ) > /config/settings.json
fi

if [ -n "${RPC_WHITELIST}" ]; then
    echo $(jq \
            --arg RPC_WHITELIST "${RPC_WHITELIST}" \
            '."rpc-whitelist-enabled" = true | ."rpc-whitelist" = $RPC_WHITELIST' \
            /config/settings.json
        ) > /config/settings.json
else
    echo $(jq \
            '."rpc-whitelist-enabled" = false' \
            /config/settings.json
        ) > /config/settings.json
fi

if [ -n "${UMASK}" ]; then
    echo $(jq \
            --arg UMASK "${UMASK}" \
            '."umask" = $UMASK' \
            /config/settings.json
        ) > /config/settings.json
fi

exec transmission-daemon \
    --foreground \
    --config-dir=/config \
    --logfile=/config/log/daemon.log
