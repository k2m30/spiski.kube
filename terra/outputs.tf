output "cluster" {
  value = libvirt_domain.kube-cluster.*
}

output "ips" {
  value = tomap({
  for node, info in libvirt_domain.kube-cluster : node => info.network_interface.*.addresses[0][0]
  })
}