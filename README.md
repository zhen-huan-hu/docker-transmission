# docker-transmission
Dockerfile for Transmission Daemon 4.0.0+

Credit goes to @Nemric and @pigsyn:
 - https://github.com/transmission/transmission/discussions/3885#discussioncomment-4372088
 - https://github.com/Relativ-IT/TransmissionBT

The image listens to port `51413` by default for torrent traffic and port `9091` for RPC connection.
There is a built-in Web UI that can be connected at port `9091` through a web browser.
Users can also launch the Qt client to remotely control the daemon (thin-client mode).

The image expects three bind volumes: `\config` for configuratoin directory,
`\watch` for watch directory, and `\download` for default download location.
By default, having a standalone directory for incomplete torrent files is disabled.

The image honors the `--user` option for setting user and group ID inside the container, and the `--group-add` option for setting secondary groups.

## Build an Docker Image

```
docker build -t transmission:latest-alpine .
```

## Usage

### Docker compose

```
version: '2.4'

services:
  transmission:
    image: transmission:latest-alpine
    container_name: transmission
    restart: unless-stopped
    user: "1000:1000"
    ports:
      - "51413:51413/tcp"
      - "51413:51413/udp"
      - "9091:9091/tcp"
    environment:
      - RPC_USER=admin
      - RPC_PASSWORD=password
      - RPC_WHITELIST=127.0.0.1,192.168.1.*
      - UMASK=002
      - TZ=America/Chicago
    volumes:
      - /var/containers/transmission/config:/config
      - /var/containers/transmission/watch:/watch
      - /var/containers/transmission/download:/download
```

### Docker CLI

```
docker run -d \
  --name transmission \
  --restart unless-stopped \
  --user 1000:1000 \
  -p 51413:51413/tcp \
  -p 51413:51413/udp \
  -p 9091:9091/tcp \
  -e RPC_USER=admin \
  -e RPC_PASSWORD=password \
  -e RPC_WHITELIST=127.0.0.1,192.168.1.* \
  -e UMASK=002 \
  -e TZ=America/Chicago \
  -v /var/containers/transmission/config:/config \
  -v /var/containers/transmission/watch:/watch \
  -v /var/containers/transmission/download:/download \
  transmission:latest-alpine
```

## Environment Variables

| Name | Function |
| --- | --- |
| `RPC_USER` | Set RPC user name |
| `RPC_PASSWORD` | Set RPC password |
| `RPC_WHITELIST` | Set comma-delimited list of IP addresses allowed for RPC |
| `RPC_HOST_WHITELIST` | Set white list of domain names allowed for the host |
| `UMASK` | Change default file permission https://en.wikipedia.org/wiki/Umask |
| `TZ` | Change default time zone |
