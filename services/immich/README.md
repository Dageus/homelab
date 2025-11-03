# Immich

Immich is an open-source image library that has incredibly useful features, on par with proprietary software like Google Photos and Apple. It has AI face indexing running 100% locally and very friendly UI, with an equally friendly mobile app which ties it all together as an extremely good software to have if you're planning on having a NAS.

#### Sources

[https://www.reddit.com/r/Proxmox/comments/1lxtdyb/immich_lxc_point_to_nas_for_storage/](https://www.reddit.com/r/Proxmox/comments/1lxtdyb/immich_lxc_point_to_nas_for_storage/)

[https://pve.proxmox.com/wiki/Linux_Container#_bind_mount_points](https://pve.proxmox.com/wiki/Linux_Container#_bind_mount_points)

## Repo

[https://github.com/immich-app/immich](https://github.com/immich-app/immich)

## Guide

BEFORE STARTING TO INSTALL IMMICH, IT'S BETTER TO HAVE A [NAS](https://en.wikipedia.org/wiki/Network-attached_storage) SET UP.

ADDITIONALLY, CHECK THE GUIDE FOR [MOUNTING FOLDERS IN AN LXC](../../docs/proxmox/mounting_folders_in_lxc.md).

---

## If using NFS mounted folder

#### Sources

[https://docs.immich.app/guides/custom-locations/](https://docs.immich.app/guides/custom-locations/)


[https://www.reddit.com/r/immich/comments/1cr22nx/where_are_thumbnails_kept_an_can_they_be_stored/](https://www.reddit.com/r/immich/comments/1cr22nx/where_are_thumbnails_kept_an_can_they_be_stored/)

[https://github.com/community-scripts/ProxmoxVE/discussions/5075](https://github.com/community-scripts/ProxmoxVE/discussions/5075)

If you're using an NFS mounted folder on your LXC, and then bypass it to the docker image, you should probably try to save the thumbnails directly on the LXC, for faster preview of the images. This can be done by altering the volumes in the `docker-compose.yml`:

```yml
- ${HOST_THUMBNAIL_LOCATION}:/data/thumbs
- ${NFS_FOLDER}:/data
```

## Speeding up Facial Recognition using GPU Passthrough

#### Sources

[https://forum.proxmox.com/threads/gpu-passthrough-to-container-lxc.132518/](https://forum.proxmox.com/threads/gpu-passthrough-to-container-lxc.132518/)

[https://jellyfin.org/docs/general/post-install/transcoding/hardware-acceleration/intel/#lxc-on-proxmox](https://jellyfin.org/docs/general/post-install/transcoding/hardware-acceleration/intel/#lxc-on-proxmox)

## Backing up Google Photos/iOS Cloud to Immich

Thankfully, the creator of Immich created a convenient CLI that connects to your google account and backs up photos from one service to another.

[https://github.com/simulot/immich-go][https://github.com/simulot/immich-go]

You can read more about it on the repository.

But the grit of it is:
