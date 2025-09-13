# Proxmox Configuration

Proxmox is extremely good as a baseline for a server, but the amount of logs it saves and how much memory and disk space it uses, given my setup, it could hinder the performance of the services I wanted due to how much CPU and disk usage Proxmox would just by idling.

Here follows a list of the tweaks I made to my Proxmox to enhance performance and make it last longer

## Scripts

Just a small disclaimer, when it comes to scripts for Proxmox, 9 times out of 10 the [Community Scripts](https://community-scripts.github.io/ProxmoxVE/) are going to be your best friend. I just tried to do it on my own for the experience.

### How to add internal network interface with NAT

It helps freeing up physical networks ip range

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

#### sources

* [https://askubuntu.com/questions/157793/why-is-swap-being-used-even-though-i-have-plenty-of-free-ram]
* [https://askubuntu.com/questions/103915/how-do-i-configure-swappiness/103916#103916]

#### Context

The swappiness parameter controls the tendency of the kernel to move processes out of physical memory and onto the swap disk. Because disks are much slower than RAM, this can lead to slower response times for system and applications if processes are too aggressively moved out of memory.

Swappiness can have a value between 0 and 100

swappiness = 0 tells the kernel to avoid swapping processes out of physical memory for as long as possible. For kernel version 3.5 and newer it disables swappiness.

swappiness = 100 tells the kernel to aggressively swap processes out of physical memory and move them to swap cache.

The default setting in Ubuntu is swappiness = 60. A value of swappiness = 10 is recommended.

#### Commands

check swappiness value:

```bash
cat /proc/sys/vm/swappiness
```

to change the swappiness value a temporary change (lost on reboot) with a swappiness of 10 can be made with

```bash
sysctl vm.swappiness=10
```

to make the change permanent, edit the configuration file with your prefered editor:

```bash
vim /etc/sysctl.conf
```

search for 'vm.swappiness' and change its value as desired. if vm.swappiness does not exist, add it at the end of the file like so:

```ini
vm.swappiness=10
```

run `sysctl --load=/etc/sysctl.conf` after editing the file to apply the changes

### Disable HA services

#### sources

[https://www.reddit.com/r/Proxmox/comments/129dxw7/proxmox_high_disk_writes](https://www.reddit.com/r/Proxmox/comments/129dxw7/proxmox_high_disk_writes)

#### commands

run these commands to limit the amount of writes:

```bash
systemctl disable --now pve-ha-crm.service
systemctl disable --now pve-ha-lrm.service
systemctl disable --now corosync.service
```

those settings disable the high availability and clustering features (who are write intensive)

### Enable SSD trim

```bash
systemctl start fstrim.service
systemctl status fstrim.service
```

### Extend the local lvm volume after first install

```bash
pvs
vgs
lvs
lsblk
lvresize -l +100%FREE pve/data
```

### Change CPU governor to conservative

This will increase powersaving features and improve dynamic CPU frequence

#### sources

[https://forum.proxmox.com/threads/fix-always-high-cpu-frequency-in-proxmox-host.84271/](https://forum.proxmox.com/threads/fix-always-high-cpu-frequency-in-proxmox-host.84270/)


```bash
apt-get update
apt-get install acpi-support acpid acpi
```

Edit the file `/etc/default/grub` and add

```ini
intel_pstate=disable to GRUB_CMDLINE_LINUX_DEFAULT
GRUB_CMDLINE_LINUX_DEFAULT="intel_pstate=disable"
```

then run:

```bash
update-grub
reboot
```

After reboot run the command below to set CPU governor as conservative:
(this command will set all CPU to conservative mode, most of the CPU available governor using acpi will be)
(conservative ondemand userspace powersave performance schedutil)
(you can contrab -e and put below the command with @reboot)

```bash
echo "conservative" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

You can use `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors` to see which governors are available

this is how it should look on crontab:

```bash
@reboot echo "conservative | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

install i7z using apt so you can check real time CPU frequency and temperatures

### NOTE:

When installing Proxmox, I chose ext4 instead of zfs or btrfs, otherwise I could suffer from write amplification, which can kill SSD's faster

### Installing the community repo for proxmox

#### sources

[https://medium.com/@ronyhanna/proxmox-ve-post-installation-and-configuration-part-02-5f9c948371bb#1679](https://medium.com/@ronyhanna/proxmox-ve-post-installation-and-configuration-part-02-5f9c948371bb#1679)

#### Commands

* Select the node in the GUI

* Expand Updates

* Select repositories

* Select Add from the GUI

* Select "No-Subscription Repository"

* Select Add

Now we have to disable the "enterprise repository" and "pve-enterprise repository"

* Select on the enterprise repository

* Hit Disable

* Select on the pve-enterprise repository

* Hit Disable

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

### Community Post-Install Script

download the script from

* [https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install]

say "no" to installing the ceph repository and pvetest repository, since it is extremely unstable.
say "no" to high availability since that will increase disk writes and a regular PC won't benefit from it.

### Removing 'local-lvm'

Since we'll be using proxmox as a homelab setup, we don't need a lot of snapshots and provisioning, so we can safely remove 'local-lvm', improving our disk space and having just one central directory.

### Creating your first template

It's very useful to have an easy template if all your services require the same base setup (in my case, a Docker-ready container where I just need to deploy the service). This is a very strong feature of Proxmox.

Follow the steps denoted in `creating_debian_lxc_container.md`.

In my case, since everything will be running on top of docker, we'll need to install it.

```bash
apt install lsb-release gnupg2
apt-transport-https ca-certificates curl
software-properties-common -y
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/debian.gpg

add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

apt update
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl start docker && systemctl enable docker

systemctl status docker
docker version
```

There also a service that was disabled to avoid 5-minute delay for the services to start: `ifupdown-wait-online.service`

```bash
systemctl status ifupdown-wait-online.service
systemctl disable ifupdown-wait-online.service
```

LXC containers don't generally have sudo; if you want to shh with root, you need to change `/etc/ssh/sshd_config` and change "PermitRootLogin" to Yes

Lastly, run `dpkg-reconfigure locales` and choose your prefered locale.

To clean up some extra space that might've come with the installed packages, run:

```bash
apt clean -q && apt update -q && apt dist-upgrade -y && apt autoremove -y
```

To convert this into a template, right click the newly created container and click "Convert to template"

#### IMPORTANT NOTE:

Always clone using "Full Clone", never use "Linked Clone"

#### Special Note for Wireguard container

In case you're using this to deploy wireguard, inside your node shell, go to `/etc/pve/lxc/<lxc_id>.conf` and add:

```ini
lxc.apparmor.profile: unconfined
lxc.cgroup.device.allow: a
lxc.cap.drop:
lxc.cgroup2.devices.allow c 10:200 rwm
lxc.mount.entry: /dev/net/tun /dev/net/tun none bind, create=file
```
