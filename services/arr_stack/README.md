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

### AirVPN

#### Wireguard Config

After purchasing your AirVPN subscription, you'll want to go to Client Area > Config Generator.

- Choose Linux as your OS

- WireGuard as your protocol

- Choose your preferred country or continent (I chose Europe)

- Scroll down and click Generate

#### Port forwarding

- Go to Client Area > Ports.

- Let it auto-generate a port.

- Copy that port into your gluetun configuration as `FIREWALL_VPN_INPUT_PORTS`

- Copy that port into your settings in qBittorrent (WebUI > Settings > Connection > Port used for incoming connections)

## Adding qBittorrent as a Download client

- Settings > Download Clients

- Torrents > qBittorrent

- If using the gluetun network, leave it as `localhost:8080`, else use the container name (`qbittorrent`) or the vpn container name (`gluetun`).

## Prowlarr

### Adding Flaresolverr as an Indexer Proxy

- Go to Settings > Indexers.

- There's a `+` to add an Indexer Proxy.

- Select Flaresolverr

- Add the "flaresolverr" tag

- If Flaresolverr is using your gluetun network, leave it as `http://localhost:8191`, otherwise use the defined hostname.

### Adding Apps

Do this for all apps (radarr, sonarr, lidarr, etc.)

In the App:

- Settings > General

- Copy the API key

In Prowlarr:

- Settings > Apps

- Add a new App

- Set the API key of the app

- Use the container name as the server name for the app

- If using VPN, set Prowlarr server to `gluetun`, otherwise use `prowlarr`

- Test the connection

## qBittorrent

The default use is `admin`.

To see the generated password, log into the LXC and run:

```
docker logs qbittorrent
```

It should be near the tail of the logs.

### Tweaks

- Default torrent management mode: `Automatic`

- Uncheck `Use UPnP / NAT-PMP port forwarding from my router`

- Disable `DHT`, `PeX` and `Local Peer Discovery`

- Network interface: `tun0`

- Disk cache: `1024MiB`

- Asynchronous I/O threads: 

## Seerr

- Add your jellyfin's URL or IP

- Set your jellyfin username and password

- Set a valid email address

- If seerr is behind a reverse proxy, don't set a base URL

- Sync your Jellyfin libraries (if there are no libraries Seerr will get stuck)

### Adding media

Add your sonarr and radarr servers to Seerr so it can request movies.

## Pipeline

1. You request a movie via Seerr

2. Seerr requests to movie to radarr/sonarr

3. radarr/sonarr requests the movie to prowlar

4. prowlarr goes through your trackers and finds a magnet/torrent link

5. passes it back to radarr/sonarr

6. radarr/sonarr schedule the media to qbittorrent

## Library

## My trackers

- TorrentLeech

- RuTracker

- Milkie

- TorrentGalaxy

### For the future

- FileCoin

### Improving ratio in private trackers

You cans see in my docker-compose that I have [autobrr](https://github.com/autobrr/autobrr) in there.

It's an extremely fast download automation tools that allows me to be one of the first few to see when FREELEECH are announced.

Configure your Indexers in the settings, and connect your qBittorrent client.

Then create a filter for FREELEECH that triggers an action in qBittorrent and you're good to go.

## Hosting

I planned to host the entire stack via a VM, but managing folder permissions for Jellyfin (in an external LXC) would be a nightmare,
and this only start being a serious solution once I have a separate NAS, so for now it will be an **LXC** for now.

See my [`docker-compose.yml`](./docker-compose.yml) for an example when deploying the stack.

I set `PID` and `GID` to 0 because I'm running an unprivileged container. If you run a VM or a privileged container, use the default 1000.

## The Bible

Regarding hosting best practices, folder structure, docker-compose files, EVERYTHING you'll ever need to be able to host your *arr stack is in the [TRaSH guides](https://trash-guides.info/)
