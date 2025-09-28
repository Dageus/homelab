# Creating a Debian LXC

## What's an LXC?

LXC or Containers are the "mid-way" point between running an application directly on the OS or in a full VM.

The container uses the host kernel but has it's own libraries and can request root access when needed.

Since it uses the host kernel, the overhead for containers is minimal.

LXC containers are a separate category from Docker containers.

LXC provides a very minimal OS, whereas Docker is aimed at just running applications.

LXC aren't inherently secure, since although it uses a different namespace there can still be some issues.

Additionally, LXC can't be live migrated from one Proxmox instance to another.

## Installing a container

Before creating a container, we need a template.

There are hundreds of templates to choose from in the proxmo web GUI, and if you need a specific use, you can even make your own templates (we'll get into this later)

In the UI, after choosing the template you want and choosing 'local' storage, you can go ahead and click on the "Create CT" button.

Select the node you want to deploy it on, and give it a hostname (its good if it's something that identifies the service you'll be deploying).

Lastly, just give it a password and click "Next".

The next page will prompt you to choose the template you want; I generally pick Debian 12 because it's lightweight and very stable.

Now you'll need to set up the virtual disks in your container. If you want loosely coupled services, you might deploy 1-2 services per container. If this is the case, you don't need a lot of storage or memory in the container. I mostly give it 4-8 GiB of disk storage, but that depends on how much you're willing to provide to this container.

If you removed 'local-lvm', you'll just have one disk, pick that one and click next.

For small services, you can just allocate 1-2 cores, and generally you won't need more than that.

For memory, 256-512 MiB is usually enough since the containers are so lightweight.

If you followed all the steps in the guide and you don't have a DHCP server, therefore you'll need to manually assign a static IPv4 address (leave the IPv6 empty)

Then just select 'use host settings' in the DNS section and click finish. The container will start building.

And you're done!

### Additional notes

If you're feeling adventurous and want to start automating processes already, you can enable automatic updates on the container.

start by installing the necessary packages:

```sh
apt update
apt install unattended-upgrades
```

By default almost all automatic updates are turned off. Open `/etc/apt/apt.conf.d/50unattended-upgrades` and add this:

```
"origin=Debian,codename=${distro_codename}-updates";
"origin=Debian,codename=${distro_codename},label=Debian";
"origin=Debian,codename=${distro_codename},label=Debian-Security";
"origin=Debian,codename=${distro_codename}-security,label=Debian-Security";
```

If you also want to include the Proxmox repository in the updates, add this line:

`"origin=Proxmox,codename=${distro_codename},label=Proxmox Debian Repository";`

If you have docker, it goes like this:

`"origin=Docker,codename=${distro_codename},label=Docker";`

The official page for unattended upgrades recommends uncommenting/adding the line:

`Unattended-Upgrade::Mail "root";`

This make the system send a list of changes by email to the user.

If you don't want to bloat your root partition, it might be a good idea to remove packages that are no longer required as dependencies. 

To turn this on, add this line:

`Unattended-Upgrade::Remove-Unused-Dependencies "true";`

### Enable automatic updates

To turn this feature on, we need to tweak `/etc/apt/apt.conf.d/20auto-upgrades`.

This can be done by running `dpkg-reconfigure`:

```sh
dpkg-reconfigure --priority=low unattended-upgrades
```

To check the status of the service (to see if it's running), run:

```sh
systemctl status unattended-upgrades.service
```

If the system is not enabled, run:

```sh
systemctl enable unattended-upgrades
systemctl start unattended-upgrades
```

The logs can be seen in `/var/log/unattended-upgrades/`

And this is generally the configurations you need for your LXC containers, of course there are a lot more options, but for starters this is good enough.
