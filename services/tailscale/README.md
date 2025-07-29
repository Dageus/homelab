# Tailscale

Tailscale is the fastest and easiest approach to have a VPN setup to connect to your home network and homelab.

For improved security it's recommended to run wireguard on it's own, because Tailscale needs a central hub to forward communications, so it's not entirely private.

For this case, I created an auth key in the Keys section on the Tailscale admin panel, added the tag container to it (you need to alter the access JSON file to create tags)

and then used the docker compose here to deploy it inside an LXC.
