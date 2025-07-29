# Homelab Setup

## Useful links

Setuping up XPEnology (cracked version of Synology):
- * [https://blog.nootch.net/post/poor-mans-synology-nas-on-proxmox/]

## Hardware
## OS Journey
## Proxmox Breakthrough
## What’s Next?

This started as a side project since one of my family members wanted to sell their computer, and I offered to keep it for free if I made it useful.

This then led me down a rabbit hole where I found out I actually have a passion for Systems Administration and had fun like I've never had before.

## Computer specs

The computer has some measly specs, but that was more than enough to have fun with deploying services.

---

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

### Key Takeaways  
- **Arch Linux ≠ Server OS**: Stability > bleeding-edge for homelabs.  
- **Proxmox is a Game-Changer**: Virtualization simplified my Docker/LXC workflows.  
- "YouTube University" is valid – but cross-reference docs!  

## Next Steps  
- Deep-dive into my Cloudflare Tunnel setup.  
- Kubernetes on a shoestring budget? Challenge accepted.  
