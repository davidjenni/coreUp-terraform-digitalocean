output "ipv4_addresses" {
  value       = ["${digitalocean_droplet.manager.*.ipv4_address}"]
  description = "The manager nodes' public ipv4 adresses"
}

output "ipv4_addresses_private" {
  value       = ["${digitalocean_droplet.manager.*.ipv4_address_private}"]
  description = "The manager nodes' private ipv4 adresses"
}

output "sshKeyFile" {
  value       = "${var.provision_ssh_priv_key}"
  description = "path to SSH private key file"
}
