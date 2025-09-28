# Docs and Guides

## Useful links

Setuping up XPEnology (cracked version of Synology):
[https://blog.nootch.net/post/poor-mans-synology-nas-on-proxmox/](https://blog.nootch.net/post/poor-mans-synology-nas-on-proxmox/)

This started as a side project since one of my family members wanted to sell their computer, and I offered to keep it for free if I made it useful.

This then led me down a rabbit hole where I found out I actually have a passion for Systems Administration and DevOps.

## Computer specs

The computer has some measly specs, but that was more than enough to have fun with deploying services.

### Hardware

Model: Samsung 900X3C/900X3D/900X3E/900X4C/900X4D

Specs:

- **CPU**: Intel i5-3317U @ 1.70GHz
- **RAM**: 8GB (2x4GB) – Upgradable to 32GB
- **GPU**: Intel Integrated Graphics

## Journey

I had already set up several Linux systems, on my home computer I have Arch (previously was Ubuntu, and planning to migrate to NixOS soon...), and my work computer I have Arch as well.

So, by instinct, I installed Arch on the future server as well, only to soon find out it wasn't a very good idea.

After seeing how hard it is to get an Arch Linux setup to work as a server, I migrated to Debian, which is very famous for being lightweight and reliable.

I tried to deploy some docker containers, like an SMB filesystem to let me access photos (my Google Photos storage was full, classic story), but then found out about a very interesting OS: proxmox.

Built on top of Debian (already a plus for me), proxmox was exactly what I was looking for since I wanted to mess with virtualization: everything is running on either VM's or LXC's, everything virtualized, and a simple web-interface to go with it.

Then, after watching a ton of Youtube videos regarding initial setup's for proxmox, I had my first template ready and started deploying services, and the rest is history.

I wanted to document this journey for anyone who wants to start messing with proxmox (I know a lot of guides are out there, but I hope to bring more diversity to the already existing solutions).


## Current Architecture

#### Inspiration

[https://www.reddit.com/r/homelab/comments/nf40iy/some_major_homelab_updates_have_come_along_so_its/#lightbox](https://www.reddit.com/r/homelab/comments/nf40iy/some_major_homelab_updates_have_come_along_so_its/#lightbox)

![Architecture](./assets/network.svg)

## Current Setup

My current setup is [Proxmox 9.x](https://www.proxmox.com/en/about/company-details/press-releases/proxmox-virtual-environment-9-0), currently being replicated using IaC, see my [guide](../scripts/README.md) about getting started on replicating your Proxmox setup and using IaC tools.

If you want to learn more about how I got the most out of this 8 year old PC (not without it's drawbacks), read my [guide](./proxmox/README.md) on setting up and optimizing proxmox.
