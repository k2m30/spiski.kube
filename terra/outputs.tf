output "all" {
  value = libvirt_domain.kube-cluster.*
}

output "kmaster" {
  value = libvirt_domain.kube-cluster["kmaster"].network_interface.*.addresses
}

output "kworker" {
  value = libvirt_domain.kube-cluster["kworker"].network_interface.*.addresses
}