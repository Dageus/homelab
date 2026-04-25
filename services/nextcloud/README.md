# Nextcloud

### Repo

[https://github.com/nextcloud/server](https://github.com/nextcloud/server)

### Website

[https://nextcloud.com/](https://nextcloud.com/)

## Guide

Nextcloud offers a lot of different community [Docker compose examples](https://github.com/nextcloud/docker/blob/master/.examples/docker-compose/).

Pick one that fits you, and use it.

> [!NOTE]
> If using a reverse proxy (like nginx, caddy or traefik), remove the proxy and acme containers,
> your reverse proxy will handle that already

### Add missing database indices

```
docker compose exec -u www-data app php occ db:add-missing-indices
```

### Mimetype migrations

```
docker compose exec -u www-data app php occ maintenance:repair --include-expensive
```

### Maintenance

(runs at 01 AM)

```
docker compose exec -u www-data app php occ config:system:set maintenance_window_start --type=integer --value=1
```

### Add trusted ranges for Caddy

```
docker compose exec -u www-data app php occ config:system:set trusted_proxies 0 --value="<reverse_proxy_ip>/24"
docker compose exec -u www-data app php occ config:system:set trusted_proxies 1 --value="10.10.10.0/16"
```

### Adding family members

- Click on the admin user icon > Accounts

- Add new Group "Family"

- Add new users to the Group
