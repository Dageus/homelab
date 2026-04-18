# Caddy

### Repo

[https://github.com/caddyserver/caddy](https://github.com/caddyserver/caddy)

### Website

[https://caddyserver.com/](https://caddyserver.com/)

## Guide

For a functional Caddy proxy, you need 2 things:

- an email

- a "domain" (it doesn't need to be a real one)

You can check a basic Caddyfile [here](./Caddyfile).

You can have all your proxies in one giant Caddyfile, but if you notice at the end of my Caddyfile:

```
import /etc/caddy/conf.d/*.conf
```

This let's you define one small Caddyfile per service if you want.

For example, the `/etc/caddy/conf.d/immich.conf` might look like this:

```
immich.<your_domain> {
    tls {
        dns cloudflare {env.CF_API_TOKEN}
    }
    reverse_proxy <immich_ip>:2283
}
```

And this way you have a modular setup where you can add/remove apps without touching the original Caddyfile.

> [!NOTE]
> Don't forget to add a DNS rewrite to your DNS provider,
> or alter your /etc/hosts to point to Caddy.

#### Debugging proxies

```
docker exec caddy caddy adapt --config /etc/caddy/Caddyfile --pretty
docker logs --tail 50 caddy
```

### DNS Providers

Depending on your DNS provider, you may need a custom docker image.

Check [CaddyBuilds](https://github.com/CaddyBuilds/) for this.

#### DNS-01 Challenge (Cloudflare)

If you are using Cloudflare Zero Trust and a Cloudflare tunnel, you can have HTTPS in your LAN by using a DNS Challenge and **NO** ports open.

If you just have a regular public Domain obtained from a different provider, you'll need to forward ports 80 and 443 in your router.

Access you Cloudflare Dashboard, then:

- Go to Profile (top right corner in the Dashboard)

- API Tokens

- Create Token

- Create Custom Token (bottom of the page)

- Give a name to your token

- Permissions are: **Zone** -> **DNS** -> **Edit**

- Choose a TTL that ends in the far future so you don't have to worry about it

- Click "Continue to summary"

- Click "Create Token"

- Copy the API Token to your clipboard (**DO NOT LOSE IT, OTHERWISE YOU NEED TO REPEAT THE WHOLE PROCESS**)

