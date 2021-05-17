variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default = "/srv/storage/virt-storage"
}

variable "vm_hostname" {
  description = "vm hostname"
  default = "spiski.live.dev"
}

variable "ssh_username" {
  description = "the ssh user to use"
  default = "ubuntu"
}

variable "ssh_private_key" {
  description = "the private key to use"
  default = "~/.ssh/id_rsa"
}