output "ip" {
  value = libvirt_domain.kube-cluster.*.network_interface.0.addresses
}

output "hostnames" {
  value = libvirt_domain.kube-cluster.*.network_interface.0.hostname
}

output "network" {
  value = libvirt_network.kube-network
}