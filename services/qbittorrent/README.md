# Qbittorrent

Qbittorrent is one of the most trusted Torrenting software in the market, since it's open-source.

There are a lot of implementations of Qbittorrent for Docker, and a lot of debate of whether to use distro-less images or not.

After a bit of investigating, I've found out that these are really just neat-picking, and I'll list some images that are safe, light, and friendly.

For additionaly security (it's needed, trust me), we're going to tunnel Qbittorrent through a VPN.

Our VPN tunnel will be used through gluetun.

### Repo

[https://github.com/qbittorrent/qBittorrent](https://github.com/qbittorrent/qBittorrent)

### Website

[https://www.qbittorrent.org/](https://www.qbittorrent.org/)

## Guide

I host it as a docker image using [hotio's image](https://hotio.dev/containers/qbittorrent/) to serve my [*arr stack](../arr_stack/README.md).
