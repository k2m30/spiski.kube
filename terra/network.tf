resource "libvirt_network" "kube-network" {
  name = "k8s"
  mode = "nat"
  domain = "kube.local"
  addresses = [
    "10.20.30.0/24"]
  dhcp {
    enabled = true
  }

  dns {
    enabled = true
  }
}