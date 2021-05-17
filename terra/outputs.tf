output "ip" {
  value = libvirt_domain.kube-cluster.*.network_interface[0]
}

output "hostnames" {
  value = libvirt_domain.kube-cluster.*
}