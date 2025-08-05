# Set your public SSH key here
variable "ssh_public_key" {
  type        = string
  description = "Path to public ssh key"
  default     = "path/to/ssh/key"
}
# Set your private SSH key here
variable "ssh_private_key" {
  type        = string
  description = "Path to private ssh key"
  default     = "path/to/ssh/key"
}
# Establish which Proxmox host you'd like to spin a VM up on
variable "proxmox_host" {
  type        = string
  description = "The hostname for your Proxmox node"
  default     = "proxmox_host_name"
}
# Specify which template name you'd like to use
variable "template_name" {
  type        = string
  description = "The name of the template you'll be using"
  default     = "debian-12-standard_12.7-1_amd64.tar.zst"
}
# Establish which nic you would like to utilize
variable "nic_name" {
  type        = string
  description = "ID of the virtual bridge"
  default     = "vmbr<number>"
}

# Establish the VLAN you'd like to use
# variable "vlan_num" {
#   default = "place_vlan_number_here"
# }

# Provide the url of the host you would like the API to communicate on.
# It is safe to default to setting this as the URL for what you used
# as your `proxmox_host`, although they can be different
variable "api_url" {
  type        = string
  description = "URL for the proxmox API endpoint"
  default     = "https://<proxmox_host_ip>:8006/api2/json"
}
# Blank var for use by terraform.tfvars
variable "token_secret" {
}
# Blank var for use by terraform.tfvars
variable "token_id" {
}

variable "lxc_docker_template" {
  description = "Definition of LXC template used for general Docker deployments"
  type = map(object({
    template_name = string
    vmid          = number
    playbook_name = string
  }))
  default = {
    "docker_template" = {
      template_name = "debian-12-standard_12.7-1_amd64"
      vmid          = 100
      playbook_name = "docker_template.yml"
    }
  }
}

variable "lxc_hosts" {
  description = "A map of LXC hostnames and their configurations."
  type = map(object({
    vmid          = number
    playbook_name = string
  }))
  default = {
    "adguard" = {
      vmid          = 101
      playbook_name = "adguard.yml"
    }
    "tailscale" = {
      vmid          = 102
      playbook_name = "tailscale.yml"
    }
    "npm" = {
      vmid          = 103
      playbook_name = "npm.yml"
    }
    "portainer" = {
      vmid          = 104
      playbook_name = "portainer.yml"
    }
    "cloudflare" = {
      vmid          = 105
      playbook_name = "cloudflare.yml"
    }
    "glance" = {
      vmid          = 106
      playbook_name = "glance.yml"
    }
  }
}
