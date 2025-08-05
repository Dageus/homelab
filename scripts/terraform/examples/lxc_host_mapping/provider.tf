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
  # References our secrets.tfvars to plug in our token_secret 
  pm_api_token_secret = var.token_secret
  # unless you have TLS working on your proxmox server
  pm_tls_insecure = true
}
