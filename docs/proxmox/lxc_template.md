# Creating your first template

## Unprivileged LXC

It's very useful to have an easy template if all your services require the same base setup (in my case, a Docker-ready container where I just need to deploy the service). This is a very strong feature of Proxmox.

To first create a container, follow the steps denoted in [this guide](./lxc_container.md)

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

LXC containers don't generally have sudo; if you want to ssh with root, you need to change `/etc/ssh/sshd_config` and change "PermitRootLogin" to Yes.

Lastly, run `dpkg-reconfigure locales` and choose your prefered locale.

To clean up some extra space that might've come with the installed packages, run:

```bash
apt clean -q && apt update -q && apt dist-upgrade -y && apt autoremove -y
```

In the options of the LXC in the GUI, you need to enable the following options:

- `keyctl`: transforms the root actions inside a container to non-root actions on the host machine, making the container "believe" it's root

- `nesting`: allows hardware flags to be passed over virtualization (for docker uses)

- `FUSE`: short for Filesystem for Userspace, it's good for Docker-in-Docker setups for when you need to redirect filesystem calls to a userspace

To convert this into a template, right click the newly created container and click "Convert to template".

#### Important Note

Always clone using "Full Clone", never use "Linked Clone", otherwise your clone will be dependant on the template it was cloned.

#### Special Note for Wireguard container

In case you're using this to deploy wireguard, inside your node shell, go to `/etc/pve/lxc/<lxc_id>.conf` and add:

```ini
lxc.apparmor.profile: unconfined
lxc.cgroup.device.allow: a
lxc.cap.drop:
lxc.cgroup2.devices.allow c 10:200 rwm
lxc.mount.entry: /dev/net/tun /dev/net/tun none bind, create=file
```
