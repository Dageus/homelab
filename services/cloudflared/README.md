# Cloudflared

Allows running Cloudflare Tunnels

### Repo

[https://github.com/cloudflare/cloudflared](https://github.com/cloudflare/cloudflared)

### Website

[https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/)

## Guide

Travel to your Cloudflare [dashboard](https://dash.cloudflare.com) and go to `Zero Trust` > `Networks` > `Tunnels`

- Click on `Add a tunnel`

- Give a name to the tunnel

- Copy the token and save it. It only shows it __ONCE__

- Save the token to the `CLOUDFLARE_TUNNEL_TOKEN` variable in your `.env`

### Configuration

The rest of the configuration (routes, etc) happens via the Dashboard.
