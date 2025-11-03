# Proxmox Configuration

Proxmox is extremely good as a baseline for a server, but the amount of logs it saves and how much memory and disk space it uses, given my setup, could hinder the performance of the services I wanted due to how much CPU and disk usage Proxmox would use just by idling.

Here follows a list of the tweaks I made to my Proxmox to enhance performance and make it last longer

#### Sources

[https://forum.proxmox.com/threads/how-does-keyctl-works-in-virtual-environments.116414/](https://forum.proxmox.com/threads/how-does-keyctl-works-in-virtual-environments.116414/)

## Scripts

### How to add internal network interface with NAT

It helps freeing up physical networks ip range by making containers use they own IP range

Edit the `/etc/network/interfaces` file on the Proxmox host and add this after vmbr0 section:

```ini
auto vmbr1
iface vmbr1 inet static
    address 10.100.0.1/24
    bridge-ports none
    bridge-stp none
    bridge-fd 0
    post-up echo 1 > /proc/sys/net/ipv4/ip_forward
    post-up iptables -t nat -A POSTROUTING -s '10.100.0.0/24' -o vmbr0 -j MASQUERADE
    post-down iptables -t nat -D POSTROUTING -s '10.100.0.0/24' -o vmbr0 -j MASQUERADE
    # Proxmox internal network
```

after the edit is done, run this command on the host:

```bash
systemctl restart networking
```

When creating a CT or VM, the first eth card should be pointing to vmbr1 and have an ip address assigned manually, as there's no DHCP server for internal network.

### Reduce swappiness

#### Sources

[https://askubuntu.com/questions/157793/why-is-swap-being-used-even-though-i-have-plenty-of-free-ram](https://askubuntu.com/questions/157793/why-is-swap-being-used-even-though-i-have-plenty-of-free-ram)

[https://askubuntu.com/questions/103915/how-do-i-configure-swappiness/103916#103916](https://askubuntu.com/questions/103915/how-do-i-configure-swappiness/103916#103916)

#### Context

The swappiness parameter controls the tendency of the kernel to move processes out of physical memory and onto the swap disk. Because disks are much slower than RAM, this can lead to slower response times for system and applications if processes are too aggressively moved out of memory.

Swappiness can have a value between 0 and 100

swappiness = 0 tells the kernel to avoid swapping processes out of physical memory for as long as possible. For kernel version 3.5 and newer it disables swappiness.

swappiness = 100 tells the kernel to aggressively swap processes out of physical memory and move them to swap cache.

The default setting in Ubuntu is swappiness = 60. A value of swappiness = 10 is recommended.

#### Commands

To check the swappiness value run:

```bash
cat /proc/sys/vm/swappiness
```

To change the swappiness value a temporary change (lost on reboot) with a swappiness of 10 can be made with:

```bash
sysctl vm.swappiness=10
```

To make the change permanent, edit the configuration file with your prefered editor:

```bash
vim /etc/sysctl.conf
```

Search for 'vm.swappiness' and change its value as desired. if vm.swappiness does not exist, add it at the end of the file like so:

```ini
vm.swappiness=10
```

Run `sysctl --load=/etc/sysctl.conf` after editing the file to apply the changes

### Disable HA services

#### Sources

[https://pve.proxmox.com/wiki/High_Availability](https://pve.proxmox.com/wiki/High_Availability)

[https://www.reddit.com/r/Proxmox/comments/129dxw7/proxmox_high_disk_writes](https://www.reddit.com/r/Proxmox/comments/129dxw7/proxmox_high_disk_writes)

#### Commands

Run these commands to limit the amount of writes:

```bash
systemctl disable --now pve-ha-crm.service
systemctl disable --now pve-ha-lrm.service
systemctl disable --now corosync.service
```

Those settings disable the High Availability and clustering features (which are write intensive). If you have hardware that supports it (including SSD's with endurance) you may keep these settings.

### Enable SSD Trim

SSD Trim is a command that tell the SSD to use its "garbage collector" to erase memory blocks that are no long in use by the host OS, freeing up space (although it can weigh down the SSD's lifetime).

To enable this service, run:

```bash
systemctl start fstrim.service
systemctl status fstrim.service
```

### Extend the local lvm volume after first install

By default, Proxmox mounts several volumes as a sort of "separation of concerns". Each volume to certain storage concerns:

- "local-lvm" only stores VM's/LXC's.

- "local" only stores Backups/ISO's/Snippets/Templates as well as the root filesystem

```bash
pvs
vgs
lvs
lsblk
lvresize -l +100%FREE pve/data
```

This command will basically extend Proxmox's storage to occupy all free space left.

### Change CPU governor to conservative

This will increase powersaving features and improve dynamic CPU frequence

#### Sources

[https://forum.proxmox.com/threads/fix-always-high-cpu-frequency-in-proxmox-host.84271/](https://forum.proxmox.com/threads/fix-always-high-cpu-frequency-in-proxmox-host.84270/)

First of all, install the packages needed:

```bash
apt-get update
apt-get install acpi-support acpid acpi
```

Then, edit the file `/etc/default/grub` and add:

```ini
intel_pstate=disable to GRUB_CMDLINE_LINUX_DEFAULT
GRUB_CMDLINE_LINUX_DEFAULT="intel_pstate=disable"
```

Lastly, run:

```bash
update-grub
reboot
```

This will make your changes effective.

After reboot run the command below to set CPU governor as conservative:

```bash
echo "conservative" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

You can use `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors` to see which governors are available.

This is how it should look on crontab:

```bash
@reboot echo "conservative | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

Install i7z using apt so you can check real time CPU frequency and temperatures.

### NOTE

When installing Proxmox, I chose ext4 instead of zfs or btrfs, otherwise I could suffer from write amplification, which can kill SSD's faster.

If you want to know more about this, read about [ZFS](https://pve.proxmox.com/wiki/ZFS_on_Linux) and it's Copy-on-Write mechanism.

### Installing the community repo for proxmox

#### Sources

[https://medium.com/@ronyhanna/proxmox-ve-post-installation-and-configuration-part-02-5f9c948371bb#1679](https://medium.com/@ronyhanna/proxmox-ve-post-installation-and-configuration-part-02-5f9c948371bb#1679)

#### Commands

Log in to your ProxmoxVE dashboard (usually available through port 8006):

- Select the node in the GUI

- Expand Updates

- Select repositories

- Select Add from the GUI

- Select "No-Subscription Repository"

- Select Add

Now we have to disable the "enterprise repository" and "pve-enterprise repository":

- Select on the enterprise repository

- Hit Disable

- Select on the pve-enterprise repository

- Hit Disable

To update the proxmox host:

```bash
pveupdate
pveupgrade

apt update && apt -y dist-upgrade
```

#### Add No-Subscription to sources (for < Proxmox 7)

Go to `etc/apt/sources.list.d/proxmox.sources` and add:

```txt
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
```

### Script to update all LXC's and then the host

This is a neat script I made for myself to update all LXC's and the host, in one script so you don't have to remember it all:

```bash
#!/bin/bash
# update all containers

containers=$(pct list | awk '$2 == "running" {print $1;}')

for c in $containers
do
    name=pct exec $c cat /etc/hostname
        echo "--------------------------------"
        echo "       updating $c ($name)      "
        echo "--------------------------------"

    pct exec $c --bash -c "apt clean -q && apt update -q && apt dist-upgrade -y && apt autoremove -y"
done; wait

# lastly, update hypervisor itself

echo "--------------------------------"
echo "       updating hypervisor      "
echo "--------------------------------"

pveam update
pveupdate && pveupgrade
apt clean && apt update && apt dist-upgrade -y && apt autoremove -y
```

Then, if you don't want to worry about it at all, you can set a [cronjob](https://cronitor.io/guides/cron-jobs) for it:

```bash
# TODO: search online how to add a weekly cronjob for this script
```

### Community Post-Install Script

Download the script from:

[https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install](https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install)

Say `No` to installing the ceph repository and pvetest repository, since it is extremely unstable.

Say `No` to high availability since that will increase disk writes and a regular PC won't benefit from it.

### Removing 'local-lvm'

#### Sources

[https://forum.proxmox.com/threads/remove-local-lvm-and-increase-local.142164/](https://forum.proxmox.com/threads/remove-local-lvm-and-increase-local.142164/)

Since we'll be using proxmox as a homelab setup, we don't need a lot of snapshots and provisioning, so we can safely remove 'local-lvm', improving our disk space and having just one central directory.

## Next Steps

Now that the initial Proxmox configuration is done, you can move on to:

- Creating your first [LXC container](./lxc_container.md)

- Creating your first [Template](./lxc_template.md)

- [Mounting folders](./mounting_folders_in_lxc.md) to your LXC container

- Upgrading your Proxmox Security and Extra features

- Creating API tokens for automation
