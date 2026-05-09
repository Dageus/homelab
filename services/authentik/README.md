# Authentik

### Repo

[https://github.com/goauthentik/authentik](https://github.com/goauthentik/authentik)

### Website

[https://goauthentik.io/](https://goauthentik.io/)

## Guide

### Automated Install

If you want to automate your installation, there are 3 environment variables you can set to override user creation:

- `AUTHENTIK_BOOTSTRAP_TOKEN`

- `AUTHENTIK_BOOTSTRAP_PASSWORD`

- `AUTHENTIK_BOOSTRAP_EMAIL`

### OIDC Auth

If whatever app you are trying to protect supports OIDC (OpenID Connect), you need to enable OAuth or OpenID Connect Auth.

This involves, when creating an OIDC provider in Authentik, to save the ClientID and ClientSecret, so that you can insert them into your app's configuration.

### Proxy/Forward Auth

If it's an app with basic auth (qBittorrent, *arr), disable Auth or set it to external, and put Authentik as your forward auth 
for those specific services (this is done via **reverse proxy**).

### Adding an Application

Go to your admin interface.

- Applications > Applications

- Create an Application Name and Slug

- Choose your Provider (OIDC, SMAL, LDAP or proxy are the most common)

- Configure the Provider

- Add bindings if necessary

To "activate" the Authentication Flow, go to:

- Applications > Outposts

- Your default outpost (probably "authentik Embedded Outpost")

- Move your app from "Available Applications" to "Selected Applications"

Done!

### Scope mappings

If you had existing accounts in OAuth Apps (like Immich and Nextcloud) and don't want to rename users,
you can use a [scope mapping](https://integrations.goauthentik.io/chat-communication-collaboration/nextcloud/#create-property-mapping-optional).

### E-mail configuration

[https://docs.goauthentik.io/install-config/email/](https://docs.goauthentik.io/install-config/email/)
