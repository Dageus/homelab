# Mounting folders in LXC containers

#### Sources

[https://www.itsembedded.com/sysadmin/proxmox_bind_unprivileged_lxc/](https://www.itsembedded.com/sysadmin/proxmox_bind_unprivileged_lxc/)

[https://forum.proxmox.com/threads/tutorial-mounting-nfs-share-to-an-unprivileged-lxc.138506/](https://forum.proxmox.com/threads/tutorial-mounting-nfs-share-to-an-unprivileged-lxc.138506/)

[https://forum.proxmox.com/threads/tutorial-unprivileged-lxcs-mount-cifs-shares.101795/](https://forum.proxmox.com/threads/tutorial-unprivileged-lxcs-mount-cifs-shares.101795/)

## NFS (Unprivileged Containers)

If you are running unprivileged containers (which you should, always), the LXC doesn't have the kernel permissions to mount an NFS.

So, the NFS needs to be mounted on the proxmox host first, and then a folder needs to be mounted on the LXC, from the host, not from the NFS of the NAS.
