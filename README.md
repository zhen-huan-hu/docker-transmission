# docker-transmission
Dockerfile for Transmission Daemon 4.0.0+

Credit goes to @Nemric and @pigsyn:
 - https://github.com/transmission/transmission/discussions/3885#discussioncomment-4372088
 - https://github.com/Relativ-IT/TransmissionBT

## What's Transmission?

Transmission is a fast, easy and free bittorrent client for macOS, Windows and Linux.

## What's in This Docker Image?

This Docker image is based on Alpine Linux to minimize size.

### Listening ports

By default, the Transmission daemon listens to port `51413` for bittorrent traffic and port `9091` for RPC connection.
There is a built-in Web UI that can be connected through port `9091` in a web browser.
The user can also use the Qt client to remotely control the daemon (thin-client mode).

### Volumes

The container expects three volumes (or bind mounts):

| Volume | Usage |
| --- | --- |
| `\config` | Configuratoin directory |
| `\watch` | Watch directory |
| `\download` | Default download location |

By default, having a standalone directory for incomplete torrent files is disabled.

### Environment variables

| Name | Function |
| --- | --- |
| `RPC_USER` | Set RPC user name |
| `RPC_PASSWORD` | Set RPC password |
| `RPC_WHITELIST` | Set comma-delimited list of IP addresses allowed for RPC |
| `RPC_HOST_WHITELIST` | Set white list of domain names allowed for the host |
| `UMASK` | Change default file permission https://en.wikipedia.org/wiki/Umask |
| `TZ` | Change default time zone |

The container does not use environment variables to define process ownership.
Instead, it honors the Docker `--user` option for setting the user and group ID,
and the `--group-add` option for setting secondary group IDs.

## Usage

### How to build the image

```shell
docker build -t transmission:4.0.1-alpine .
```

### Execute Docker command in CLI

```shell
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
  transmission:4.0.1-alpine
```
### Write a `docker-compose.yml` file

```yaml
version: '2.4'

services:
  transmission:
    image: transmission:4.0.1-alpine
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