# CrowdSec

### Repo

[https://github.com/crowdsecurity/crowdsec](https://github.com/crowdsecurity/crowdsec)

### Website

[https://www.crowdsec.net/](https://www.crowdsec.net/)

## Guide

CrowdSec is ideally used alongside a **reverse proxy**, so it's best if you deploy it alongside your proxy container.

They have guides for all major reverse proxy software.

### Generating the Bouncer API key

```
docker exec -it crowdsec cscli bouncers add <reverse_proxy>-bouncer
```

or manually creating a key:

```
openssl rand -hex 16
```
