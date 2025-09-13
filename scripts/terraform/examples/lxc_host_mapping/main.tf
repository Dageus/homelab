resource "proxmox_lxc" "template" {
  hostname    = var.template.key
  target_node = var.proxmox_node
  vmid        = var.template.vmid

  ostemplate = "local:vztmpl/${var.template_name}"

  description = "Template for all future Docker deployments. Comes with all Docker dependencies ready."

  template = true

  unprivileged = true

  # TODO:
  password = ""

  # Specs of the machine
  cores  = 2
  memory = 2048
  size   = "8G"

  tags = {
    Environment = "Testing"
    Owner       = "Dageus"
    Use         = "Template"
    Deploy      = "false"
  }

  lifecycle = {
    ignore_changes = [tags]
  }
}

resource "proxmox_lxc" "container" {
  depends_on = [proxmox_lxc.template]

  for_each = var.lxc_hosts

  # Use the key as the hostname
  hostname    = each.key
  target_node = var.proxmox_node
  vmid        = each.value.vmid

  ssh_public_keys = file(var.ssh_public_key)

  # TODO:
  password = ""

  # clone our template
  clone = var.template.vmid
  full  = true

  # Network configuration
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.1.2${substr(each.value.vmid, -2, 2)}/24"
    gw     = "192.168.1.1"
  }
  network {
    name   = "eth1"
    bridge = "vmbr1"
    ip     = "10.150.0.${each.value.vmid}/24"
    gw     = "10.150.0.1"
  }

  tags = {
    Environment = "Testing"
    Owner       = "Dageus"
    Deploy      = "true"
  }

  lifecycle = {
    ignore_changes = [tags]
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/hosts.tmpl", {
    lxc_hosts = {
      for name, container in proxmox_lxc.container : name => {
        ip   = container.network[0].ip
        user = "root"
      }
    }
    ssh_private_key_path = var.ssh_private_key
  })
  filename = "${path.module}/../ansible/inventory.ini"
}
