# Nginx Proxy Manager (NPM)

Nginx-Proxy-Manager served a very specific purpose in my homelab setup.

Since I used Cloudflare Tunnel to connect my apps, there was no need for a proxy manager.

But since I deployed a XPEnology on a VM (see the guide * [here]), I wanted an easy but secure way for them to access it. This is where NPM came in.

The setup involved 2 things: Tailscale (or Wireguard) and NPM.

In this case, I used my homelab tailscale node as a subnet router to my home network, and used the same domain I had registered in cloudflared, but this time, it was NPM resolving the address.

This provided an easy way for non tech-savvy people (a.k.a. my family) to access our home NAS.

## Login Credentials

the default login credentials are:

- email: admin@example.com
- password: changeme

## Guide

First of all, deploy the NPM docker container.


