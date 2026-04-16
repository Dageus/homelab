# Open Media Vault (OMV)

Open Media Vault is an OS that turns whatever drives you feed it into a NAS. It's based on Debian Linux.

#### Sources

[https://blog.nootch.net/post/poor-mans-synology-nas-on-proxmox/](https://blog.nootch.net/post/poor-mans-synology-nas-on-proxmox/)

[https://github.com/OpenMediaVault-Plugin-Developers/installScript](https://github.com/OpenMediaVault-Plugin-Developers/installScript)

### Repo

[https://github.com/openmediavault/openmediavault](https://github.com/openmediavault/openmediavault)

### Website

[https://www.openmediavault.org/](https://www.openmediavault.org/)

## Instalation

There are 2 ways to go about installing OMV:

- Using the official ISO

- Installing it via Debian

### Official ISO

First thing's first, download the ISO file from the [official website](https://www.openmediavault.org/download.html).

Then, upload it to your Proxmox host. This can either be done through the GUI, or through [scp](https://www.w3schools.com/bash/bash_scp.php).

Next, you have to create a VM (or install it inside a separate machine for more isolation) and follow the guided instalation.

### Through Debian Cloud Image

OMV is basically a "wrap" around Debian Linux, so it is totally possible to take an existing Debian Linux ISO and turn it into OMV.

This has the benefits of being able to get a Debian Linux ISO with [cloud-init](https://cloud-init.io/) installed, so you can remotely configure the VM and automate it's creation.

Then, you can just use the install script:

```bash
wget -O - https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install | sudo bash
```

## Disk Passthrough

If you're running OpenMediaVault, chances are you want a lot of storage for it, and it's better to have OMV itself manage those disks that having proxmox as a middle-man.

This can be done through 2 ways: Proxmox shell or Terraform provisioning.

#### Proxmox Shell

When creating the VM, don't select a disk as storage and skip it.

This involves loading the node shell, either through the GUI or through SSH.

#### Terraform Provisioning

## Configuring OMV

This can have 2 paths:

- Using the WebUI (better UX)

- Using the provided CLI (good for automation)

## WebUI

### Configuring Filesystem

If you did disk passthrough, that disk will not yet have been formatted with a filesystem, so you need to choose one.

For compatibility with Linux systems and LXCs/Docker, use `ext4`.

For snapshots and data recovery, use `btrfs` (keep in mind that this filesystem has more overhead due to the snapshot capabilities).

You can do this via the `Storage` section in the dashboard.

## CLI
