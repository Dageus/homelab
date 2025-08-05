output "lxc_hostnames" {
  value       = [for instance in proxmox_lxc.test : instance.hostname]
  description = "Hostnames created"
}

# output "lxc_private_ips" {
#   value       = [for instance in proxmox_lxc.test : instance.ip]
#   description = "Private IP's attributed"
# }

output "ansible_inventory_hosts" {
  value = {
    for hostname, lxc in proxmox_lxc.container : hostname => {
      ansible_host  = lxc.network[0].ip
      ansible_user  = "root"
      playbook_name = lxc.playbook_name
    }
  }
}
