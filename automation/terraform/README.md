# Terraform

Terraform is a great tool to manage IaC (Infrastructure as Code)

In conjunction with Ansible, it can be extremely powerful for Proxmox.

## File Structure

The terraform environment is composed of (at least) 2 major files:

- `main.tf` - the program's entry point, like the main function in C, without, terraform will not work

- `variables.tf` - where you'll define your variables that can be reused for multiple deployments

other important files include:

- `provider.tf` - a file containing the information about the provider you'll be using (i.e. AWS, Azure, Proxmox, etc.)

- `output.tf` - the output of `terraform plan -out=...` to visualize what changes will be made

- `terraform.tfvars` - what will host the environment specific variables (should **not** be committed to your repository)

#### Sources

[https://registry.terraform.io/providers/bpg/proxmox/latest/docs](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)

[https://tcude.net/using-terraform-with-proxmox/](https://tcude.net/using-terraform-with-proxmox/)

[https://j.hommet.net/use-terraform-to-create-pve-lxc/](https://j.hommet.net/use-terraform-to-create-pve-lxc/)

[https://spacelift.io/blog/terraform-files](https://spacelift.io/blog/terraform-files)

## Install

To install terraform, just follow the script provided on the official website:

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update && apt install terraform
```

if you're running this inside a privileged container, be sure to use `sudo`

## Provider

There used to be a debate among users, whether [Telmate](https://registry.terraform.io/providers/Telmate/proxmox/latest) or [bpg](https://registry.terraform.io/providers/bpg/proxmox/latest) was better to provision VMs/LXCs in Proxmox. But over the years bpg has come soundly on top, encapsulating every feature proxmox has, and has a way better support for cloud-init provisioning in VMs, so that's the one I'll be using in this guide (and in my homelab of course).

## Authentication

### Create a role in Proxmox

First, create the user:

```bash
sudo pveum user add terraform@pve
```

Then, create a role for the user:

```bash
sudo pveum role add Terraform -privs "Realm.AllocateUser, VM.PowerMgmt, VM.GuestAgent.Unrestricted, Sys.Console, Sys.Audit, Sys.AccessNetwork, VM.Config.Cloudinit, VM.Replicate, Pool.Allocate, SDN.Audit, Realm.Allocate, SDN.Use, Mapping.Modify, VM.Config.Memory, VM.GuestAgent.FileSystemMgmt, VM.Allocate, SDN.Allocate, VM.Console, VM.Clone, VM.Backup, Datastore.AllocateTemplate, VM.Snapshot, VM.Config.Network, Sys.Incoming, Sys.Modify, VM.Snapshot.Rollback, VM.Config.Disk, Datastore.Allocate, VM.Config.CPU, VM.Config.CDROM, Group.Allocate, Datastore.Audit, VM.Migrate, VM.GuestAgent.FileWrite, Mapping.Use, Datastore.AllocateSpace, Sys.Syslog, VM.Config.Options, Pool.Audit, User.Modify, VM.Config.HWType, VM.Audit, Sys.PowerMgmt, VM.GuestAgent.Audit, Mapping.Audit, VM.GuestAgent.FileRead, Permissions.Modify"
```

Assign the role to the previously created user:

```bash
sudo pveum aclmod / -user terraform@pve -role Terraform
```

Afterwards, create an API Token for the created user:

```bash
sudo pveum user token add terraform@pve provider --privsep=0
```

#### Alternative (use root@pam)

If you're confident that the machine you have won't be used for malicious reasons, and that the networks you're working on is secure and won't be sniffed, you can use root@pam and create an API Token for it.

Go into the dashboard, and TODOTODOTODOTODOTODOTODO

Remember to turn off the "Privilege Separation" in the Datacenter -> Permissions -> API Tokens.

#### Note

I would advice you to save this in a file where they can be easily loaded, either a `.env` file or a custom file like `terraform.tfvars` with the format:

```ini
proxmox_api_token = "terraform@pve!terraform-token=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
```

### Auth Ticket

If you want an ephemeral way to run terraform scripts, you can request an Auth Ticket from Proxmox and use it during its session to run the terraform plan.

Thankfully, bpg's guide provides a neat bash script that only requires [curl](https://curl.se/) and [jq](https://jqlang.org/) to run and extract the auth ticket and [CRSF](https://developer.mozilla.org/en-US/docs/Web/Security/Attacks/CSRF) prevention token.

```bash
#!/usr/bin/bash

## assume vars are set: PROXMOX_VE_ENDPOINT, PROXMOX_VE_USERNAME, PROXMOX_VE_PASSWORD
## end-goal: automatically set PROXMOX_VE_AUTH_TICKET and PROXMOX_VE_CSRF_PREVENTION_TOKEN

_user_totp_password='123456' ## optional TOTP password


proxmox_api_ticket_path='api2/json/access/ticket' ## cannot have double "//" - ensure endpoint ends with a "/" and this string does not begin with a "/", or vice-versa

## call the auth api endpoint
resp=$( curl -q -s -k --data-urlencode "username=${PROXMOX_VE_USERNAME}"  --data-urlencode "password=${PROXMOX_VE_PASSWORD}"  "${PROXMOX_VE_ENDPOINT}${proxmox_api_ticket_path}" )
auth_ticket=$( jq -r '.data.ticket' <<<"${resp}" )
resp_csrf=$( jq -r '.data.CSRFPreventionToken' <<<"${resp}" )

## check if the response payload needs a TFA (totp) passed, call the auth-api endpoint again
if [[ $(jq -r '.data.NeedTFA' <<<"${resp}") == 1 ]]; then
  resp=$( curl -q -s -k  -H "CSRFPreventionToken: ${resp_csrf}" --data-urlencode  "username=${PROXMOX_VE_USERNAME}" --data-urlencode "tfa-challenge=${auth_ticket}" --data-urlencode "password=totp:${_user_totp_password}"  "${PROXMOX_VE_ENDPOINT}${proxmox_api_ticket_path}" )
  auth_ticket=$( jq -r '.data.ticket' <<<"${resp}" )
  resp_csrf=$( jq -r '.data.CSRFPreventionToken' <<<"${resp}" )
fi


export PROXMOX_VE_AUTH_TICKET="${auth_ticket}"
export PROXMOX_VE_CSRF_PREVENTION_TOKEN="${resp_csrf}"

terraform plan
```

## Terraform HCL

Terraform uses the [HCL](https://github.com/hashicorp/hcl) (HashiCorp Configuration Language) to define everything.

### Declaring variables

> I always recommend reading up on the language's [naming convention](https://www.terraform-best-practices.com/naming)

#### Locals vs. Variables

For this difference, I will quote a reddit comment that opened my eyes about the difference

(credit to [PopePoopinpants](https://www.reddit.com/user/PopePoopinpants/), great username)

> variables are for input. Things that you can change via inputs (like a vars file).
>
> locals are "private". You can only change them by altering the code.
>
> Read the documentation from hashi regarding local variables. I think in there they describe it like so:
>
> Think of your terraform as a programming function. You have values you can pass to it. Those are like tf variables. Then, you have variables inside the function that do various things, but are not a part of the interface. Consumers of your function wouldn't know anything about those private internal variables. Those are like tf locals. 

For better organization, it's always good to have a file to save your variables (this also applies to ansible)

Let's create a file called `vars.tf`:

```terraform
variable "ssh_key" {
    default = "your_public_ssh_key_here"
}

variable "proxmox_host" {
    default = "proxmox_host_name"
}

variable "template_name" {
    default = "debian-12-standard_12.7-1_amd64.tar.zst"
}

variable "ni_name" {
    default = "vmbr<number>"
}

variable "api_url" {
    default = http://<proxmox_host_ip>:8006/api2/json
}

variable "token_secret" {
}

variable "token_id" {
}
```

### Declaring providers


You can insert your providers inside a `provider.tf` file if you want more separation:


```terraform
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      # most recent version as of October 2025
      version = "0.84.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_url

  # API Token
  api_token = var.proxmox_api_token

  # Auth Ticket
  auth_ticket = var.proxmox_auth_ticket
  csrf_token  = var.proxmox_csrf_token

  # Username/Password
  insecure = true
  username = var.proxmox_user_name
  password = var.proxmox_user_password

  ssh {
    agent = true
    # by default, the provider will use the same user as the one used in PAM auth,
    # but you can override this
    username = "name"
  }
}
```

### Creating a Demo

Create a file and named whatever you want, be it `main.tf` or `demo.tf` or `vm_creation.tf` and start defining your resource(s).

You'll need to call your variable files here and establish your provider.

```terraform
resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name      = "ubuntu-template"
  node_name = var.virtual_environment_node_name

  template = true
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  efi_disk {
    datastore_id = var.datastore_id
    type         = "4m"
  }

  disk {
    datastore_id = var.datastore_id
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.virtual_environment_node_name

  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}
```

This creates a VM for us, using a well defined template and declaring all the major specs of the machine.

But how about a LXC, which is what we'll mainly use?

## Proxmox Terraform Integration

### Creating an LXC container

```terraform
resource "proxmox_virtual_environment_container" "ubuntu_container" {
  description = "Managed by Terraform"

  node_name = "first-node"
  vm_id     = 1234

  # newer linux distributions require unprivileged user namespaces
  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "terraform-provider-proxmox-ubuntu-container"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
      ]
      password = random_password.ubuntu_container_password.result
    }
  }

  network_interface {
    name = "veth0"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.ubuntu_2504_lxc_img.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type             = "ubuntu"
  }

  mount_point {
    # bind mount, *requires* root@pam authentication
    volume = "/mnt/bindmounts/shared"
    path   = "/mnt/shared"
  }

  mount_point {
    # volume mount, a new volume will be created by PVE
    volume = "local-lvm"
    size   = "10G"
    path   = "/mnt/volume"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_2504_lxc_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "first-node"
  url          = "https://mirrors.servercentral.com/ubuntu-cloud-images/releases/25.04/release/ubuntu-25.04-server-cloudimg-amd64-root.tar.xz"
}

resource "random_password" "ubuntu_container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_container_password" {
  value     = random_password.ubuntu_container_password.result
  sensitive = true
}

output "ubuntu_container_private_key" {
  value     = tls_private_key.ubuntu_container_key.private_key_pem
  sensitive = true
}

output "ubuntu_container_public_key" {
  value = tls_private_key.ubuntu_container_key.public_key_openssh
}
```

### Cloning an LXC container

This is done through the `clone` variable. In my case, it only worked if I used the **hostname** of the template, NOT the VMID.

TODOTODTODOTODTODOTODTODOTODOTOT
TODOTODTODOTODTODOTODTODOTODOTOT
TODOTODTODOTODTODOTODTODOTODOTOT
TODOTODTODOTODTODOTODTODOTODOTOT
TODOTODTODOTODTODOTODTODOTODOTOT
TODOTODTODOTODTODOTODTODOTODOTOT
TODOTODTODOTODTODOTODTODOTODOTOT

## Creating a VM

Creating a VM follows almost the same principles as creating an LXC, with more configuration.

This extra configuration comes with its own caveats. If you're dealing with a cloud image, there are some known issues. But there are solutions for them, so you just need to be on the lookout.

### Common Issues

#### Sources

[https://www.reddit.com/r/Proxmox/comments/1gujajr/first_boot_always_result_in_kernel_panic_on_new/](https://www.reddit.com/r/Proxmox/comments/1gujajr/first_boot_always_result_in_kernel_panic_on_new/)

## Running our terraform scripts

To run our scripts, let's initiate our terraform environment, by running:

```bash
terraform init
```

This will download your provider and get everything ready to be deployed.

Most guides will tell you to run `terraform apply` when you want to run your script.

But due to poor decisions made in the past (you don't wanna go through what I went), it's better to instead do:

```bash
terraform plan -out=tfplan
```

And when you want to execute it, run:

```bash
terraform apply tfplan
```

You can also see the plan by `cat`'ing it to check if all the specs are correct
