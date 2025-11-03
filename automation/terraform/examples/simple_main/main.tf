terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc03"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://<proxmox_host_ip>/api2/json"
  pm_tls_insecure = true
}


# Defining a container, in this case, Tailscale
resource "proxmox_lxc" "tailscale" {
  target_node = "pve1"
  hostname    = "tailscale"
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard.tar.gz"
  password    = "your-secure-password"
  cores       = 1
  memory      = 512
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }
}
