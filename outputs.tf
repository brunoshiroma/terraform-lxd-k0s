output "k0s-container-ip" {
  description = "IP of k0s machine"
  value       = lxd_container.k0s-001.ip_address
}

output "k0s-container-id" {
  description = "ID of k0s machine"
  value       = lxd_container.k0s-001.id
}