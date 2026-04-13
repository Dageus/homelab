# *arr stack

The *arr stack represents all the Torrent trackers and downloaders used that end with the -arr suffix. They are used to manage all types of media downloading, from Movies and TV Shows to Manga and Comics.

## My stack

To have a reliable stack (and not receive a letter from your ISP), we'll forward all traffic to a VPN tunnel (via [gluetun](https://github.com/qdm12/gluetun)).

My *arr stack will include:

- [prowlarr](https://github.com/prowlarr/prowlarr): Handles indexers for all other *arr

- [radarr](https://github.com/Radarr/Radarr): Handles scheduling of Movies

- [sonarr](https://github.com/Sonarr/Sonarr): Handles scheduling of TV series

- [bazarr](https://github.com/morpheus65535/bazarr): Handles scheduling of subtitles

## VPN

During today's age, I do NOT advice going into Torrent swarms or p2p systems without a VPN, specially if you're going to use public trackers (i.e. me).

My preferred VPN provider is [AirVPN](https://airvpn.org), since they allow port forwarding and are very transparent about allowing p2p transfers and Remote Port Forwarding on their servers

## My trackers

- TorrentLeech

- RuTracker

- Milkie

- TorrentGalaxy

### For the future

- FileCoin

## Hosting

I planned to host the entire stack via a VM, but managing folder permissions for Jellyfin (in an external LXC) would be a nightmare,
and this only start being a serious solution once I have a separate NAS, so for now it will be an **LXC** for now.

See my [`docker-compose.yml`](./docker-compose.yml) for an example when deploying the stack.

I set `PID` and `GID` to 0 because I'm running an unprivileged container. If you run a VM or a privileged container, use the default 1000.

## The Bible

Regarding hosting best practices, folder structure, docker-compose files, EVERYTHING you'll ever need to be able to host your *arr stack is in the [TRaSH guides](https://trash-guides.info/)
