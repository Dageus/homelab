# Ansible

Ansible has unmeasurable potential in proxmox, since it can automate container deployment and application update and management.

## First steps

Create an API Token for Ansible to use.

Go to Datacenter > Permissions > API Tokens.

Name the Token ID with an appropriate name (i.e. "ansible") and attribute a user to it (generally, root@pam)

Let's start defining our hosts.

After creating the container for Ansible (i chose LXC), create the necessary directories like so:

```bash
mkdir -p ~/ansible/{inventory,playbooks,roles}
```

and create the `~/ansible/inventory/hosts.yaml` file (or .ini, if you prefer that configuration)

for security, save the API key inside a vault. thankfully, ansible provides one. 

Run:

```bash
ansible-vault create proxmox-vault.yml
```

and populate with the `proxmox-vault.yml` file

save these important files inside a custom directory called `vars/`, like so:

```bash
mkdir vars && mv proxmox-vault.yml vars/
```

and then, for automation purposes, you can save your password in a file as well:

```bash
echo "your_vault_password_here" > ~/ansible/vars/.proxmox-vault-pass
chmod 600 ~/ansible/vars/.proxmox-vault-pass
```

### Roles

This is very good for reutilizing scripts across deployments, so go ahead and create a directory for roles:

```bash
mkdir roles
ansible-galaxy init roles/proxmox_lxc
```

to set up tasks for this role, add the `tasks/create_lxc.yml` file to proxmox_lxc role

then, add a `main.yml` task to the `tasks/` directory:

```yml
- name: Run creation tasks if state is present
  include_tasks: create.yml
  when: container.state == 'present'
```

then, to add global variables that can be used in any task, create the file `main.yml` inside `roles/proxmox/defaults/`:

```yml
proxmox_api_host: "proxmox.example.com" # your proxmox domain or IP
proxmox_node: 'pve'
```

## Creating your first playbook

create the file `manage-lxcs.yml` inside `playbooks/`:

```yaml
---
- name: Manage Proxmox LXC containers
  hosts: localhost
  connection: local
  gather_facts: no

  vars_files:
    - ../vars/proxmox-vault.yml


  vars:
    lxcs:
      - vmid: 110
        hostname: test01
        # OS Template
        ostemplate: ""
        storage: ""
        cores: 1
        memory: 1024
        swap: 512
        disk: ""
        net: "name=eth0,bridge=vmbr0,ip=192.168.1.210,gateway=192.168.1.1"
        password: ""
        state: present

  tasks:
    - name: Process each LXC container
      include_role:
        name: proxmox_lxc
      loop: "{{ lxcs }}"
      loop_control:
        loop_var: container
```

Having the LXC details hardcoded into the playbook is not ideal, because sometimes you want to add/alter a container and you'll need to navigate to the file and find the details.

So let's create a file that will represent our containers, called `lxcs.yml` and located inside `vars/`

```yml
    lxcs:
      - vmid: 110
        hostname: test01
        # OS Template
        ostemplate: ""
        storage: ""
        cores: 1
        memory: 1024
        swap: 512
        disk: ""
        net: "name=eth0,bridge=vmbr0,ip=192.168.1.210,gateway=192.168.1.1"
        password: ""
        state: present
```

then, in the playbook, simply load the lxcs like you did the vault file:

```yml
---
- name: Manage Proxmox LXC containers
  hosts: localhost
  connection: local
  gather_facts: no

  # Load credentials and LXC definitions
  vars_files:
    - ../vars/proxmox-vault.yml
    - ../vars/lxcs.yaml

  tasks:
    - name: Process each LXC container
      include_role:
        name: proxmox_lxc
      loop: "{{ lxcs }}"
      loop_control:
        loop_var: container
```

## Mapping directories

create a `ansible.cfg` file inside `ansible/` so we can map everything and get a pretty setup:

```ini
[defaults]
inventory = inventory
roles_path = roles
```

## Setting up variables in roles

inside `roles/proxmox_lxc/defaults/main.yml`, populate the file:

```yml
---
# Connection Variables
proxmox_api_host: "192.168.1.75"          # Your Proxmox server IP/hostname
proxmox_api_port: "8006"                 # Proxmox API port (default 8006)
proxmox_node: "pve"                      # Your Proxmox node name (run `hostname` on Proxmox)
proxmox_user: "root@pam"                 # Authentication user
proxmox_password: ""                     # Leave empty, use Ansible Vault or env vars
proxmox_validate_certs: false            # Set to true if using valid SSL certs

# VM/LXC Defaults
proxmox_vm_id_start: 9000                # Starting ID for new VMs/LXCs
proxmox_default_storage: "local-lvm"     # Storage pool name
proxmox_default_network: "vmbr0"         # Default bridge interface

# Template Settings
proxmox_template_vm: "debian-12-template" # Your base template name
proxmox_lxc_privileged: false             # For Docker/LXC nesting
```

## Setting VMID's dynamically

```yml
    - name: Set IP based on VMID
      set_fact:
        container_ip: "192.168.1.{{ 100 + (vmid|int - vmid_base) }}"
        container_cidr: "{{ container_ip }}/24"

    # Usage in LXC config
    # netif: "name=eth0,bridge=vmbr0,ip={{ container_cidr }},gw=192.168.1.1"
```

## Setting IP addresses dynamically

```yml
- name: Get next available VMID
  uri:
    url: "https://{{ proxmox_api_host }}:8006/api2/json/cluster/nextid"
    method: GET
    headers:
      Authorization: "PVEAPIToken={{ proxmox_api_token_id }}={{ proxmox_api_token_secret }}"
    validate_certs: false
  register: next_vmid

- name: Create LXC with dynamic ID
  community.general.proxmox:
    api_host: "{{ proxmox_api_host }}"
    vmid: "{{ next_vmid.json.data | int }}"  # Convert to integer
    hostname: "container-{{ next_vmid.json.data }}"
```

## Sequence

1. Get VMID

2. Based on VMID, set IP

3. Create VM (with cloud-init integration)

Try to ping the VM/LXC to check for errors
