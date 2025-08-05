# Terraform

Terraform is a great tool to manage IaC (Infrastructure as Code)

In conjunction with Ansible, it can be extremely powerful for proxmox.

## File Structure

The terraform environment is composed of (at least) 2 major files:

- `main.tf` - the program's entry point, like the main function in C, without, terraform will not work

- `variables.tf` - where you'll define your variables that can be reused for multiple deployments

other important files include:

- `provider.tf` - a file containing the information about the provider you'll be using (i.e. AWS, Azure, Proxmox, etc.)

- `output.tf` - the output of `terraform plan -out=...` to visualize what changes will be made

- `terraform.tfvars` - what will host the environment specific variables (should **not** be committed to your repository)

## Sources

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

### Create a role in Proxmox

```bash
pveum role add terraform-role -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"
```

creating the user:

```bash
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role terraform-role
pveum user token add terraform@pve terraform-token --privsep=0
```

I would advice you to save this in a file where they can be easily loaded, either a `.env` file or a custom file like `terraform.tfvars` with the format:

```ini
token_secret = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
token_id = "terraform@pve!terraform-token"
```

### Declaring variables

> I always recommend reading up on the language's naming convention [here](https://www.terraform-best-practices.com/naming)

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
            source = "telmate/proxmox"
            # most recent version as of 29 of July 2025
            version = "3.0.2-rc03"
        }
    }
}

provider "proxmox" {
    # this is how we'll reference our vars file
    pm_api_url = var.api_url

    # references our secrets.tfvars files
    pm_api_token_id = var.token_id

    pm_api_token_secret = var.token_secret

    # unless you have TLS working on your proxmox server
    pm_tls_insecure = true

    ssh {
        agent = true
        username = var.pve_api_user
    }
}
```

### Creating the `main.tf` file

The main.tf file is where everything comes together. Think of it like the `int main() { return 0; }` in C or `public static void main(String[] args) {}` in Java; without it, the program won't work.

You'll need to call your variable files here and establish your provider.


```terraform
resource "proxmox_vm_qemu" "test_demo" {
    name = "test_vm$(count.index + 1)" # count.index starts at 0
    count = 1                          # number of VMs to be created
    target = var.proxmox_host

    # reference our template
    clone = var.template_name
    # creates a full clone instead of a linked one (generally always pick full clone)
    full_clone = true

    # VM settings
    agent = 1                         # enables 'qemu-guest-agent'
    os_type = 'cloud-init'
    cores = 2
    sockets = 1
    cpu = "host"
    memory = 4096
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"

    disk {
        slot = 0
        size = "50G"
        type = "scsi"
        storage = "name-of-storage-device"
        ssd = # enable SSD emulation
    }

    network {
        model = "virtio"
        bridge = var.ni_name
        # additionally, you can use tags to attribute a VLAN to the VM/LXC
    }

    lifecycle {
        ignore_changes = [
            network, # don't want any changes happening to the bridge or IP address
        ]
    }
}
```

this creates a VM for us, using a well defined template and declaring all the major specs of the machine. 

But how about a LXC, which is what we'll mainly use?

### Creating an LXC container

```terraform
resource “proxmox_lxc” “test_container” {
    count = 1
    target_node = var.proxmox_host
    ostemplate = var.template_name # Specify your OS template
    password = var.password # Root password for the LXC container
    cores = 2
    memory = 2048
    swap = 512

    rootfs {
        storage = “local-lvm”
        size = “10G”
    }

    network {
        name = “eth0”
        bridge = “vmbr0”
        ip = “${var.lxc_ip}/24”
        gw = var.gateway
    }

    hostname = var.container_name
}
```

## Deploying our first container

To deploy our first container, let's initiate our terraform environment, by running:

```bash
terraform init
```

this will download your provider and get everything ready to be deployed.

most guides will tell you to run `terraform apply` when you want to run your script.

But due to poor decisions made in the past (you don't wanna go through what I went), it's better to instead do:

```bash
terraform plan -out=tfplan
```

and when you want to execute it, run

```bash
terraform apply tfplan
```

you can also see the plan by cat'ing it to check if all the specs are correct

## Special case for my setup

For my setup, I wanted completely similar LXC's (didn't really bother to see the minimum specs to run each service, so I just used a good amount that wouldn't compromise my system even if 20+ containers were running) with different hostnames (and then those hostnames would be mapped to specific playbooks).

This made me tweak my `variables.tf` file to match my needs; this also led me to find out terraform is extremely formidable with what you can do to dynamically deploy containers.

First, I needed to map out the hostnames to the playbooks. Thankfully, terraform comes with built-in maps, so all I had to do was:

```terraform
variable "hosts" {
    description = "Map of LXC hosts to their playbooks"
    type = map(object({
        template_name = string
        playbook_name = string
    }))

    default = {"..."}
}
```

this allowed me to have all LXC's built from the same template (since all services except adguard don't need a lot of ram) and by using the `for_each` keyword in my `main.tf`, I'm able the individual setup of each LXC to its playbook.

this can be seen in `examples/lxc_host_mapping`

#### Challenges

Suffice to say that the hardest part of this was finding a way to generate an Ansible inventory from the terraform outputs. I tried creating a python script that migrated the output from `outputs.tf` to a config file for Ansible to read; i tried using command line, mixing `jq` to parse the values from the output to YAML; but in the end, I just decided to use Terraform only code, through the use of [template files](https://developer.hashicorp.com/terraform/language/functions/templatefile). This seemed more complex at face-value, but turned out to be easier to manage.

### Sources

[https://stackoverflow.com/questions/45489534/best-way-currently-to-create-an-ansible-inventory-from-terraform](https://stackoverflow.com/questions/45489534/best-way-currently-to-create-an-ansible-inventory-from-terraform)

[https://www.percona.com/blog/how-to-generate-an-ansible-inventory-with-terraform/](https://www.percona.com/blog/how-to-generate-an-ansible-inventory-with-terraform/)
