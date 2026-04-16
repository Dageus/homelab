# Tailscale

Tailscale is the fastest and easiest approach to have a VPN setup to connect to your home network and homelab.

For improved security it's recommended to run wireguard on it's own, because Tailscale needs a central hub to forward communications, so it's not entirely private.

For this case, I created an auth key in the Keys section on the Tailscale admin panel, added the tag container to it (you need to alter the access JSON file to create tags)

And then used the docker compose here to deploy it inside an LXC.

### Repo

[https://github.com/tailscale/tailscale](https://github.com/tailscale/tailscale)

### Website

[https://tailscale.com/](https://tailscale.com/)

## Guide

[TODO:] #

### Auth Key for Docker

To generate an auth key, go to the `Keys` section of the admin console.

- Click on `Generate auth key...`

- Give it a description

- Leave `Reusable` off (so there's no chance of using it twice)

- Copy the key. It only shows it __ONCE__

- Inject it in the `TS_AUTHKEY` environment variable of the container
