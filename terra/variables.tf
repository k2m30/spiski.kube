variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default = "/srv/storage/virt-storage/kube"
}

variable "ssh_username" {
  description = "the ssh user to use"
  default = "user"
}

variable "ssh_private_key" {
  description = "the private key to use"
  default = "~/.ssh/id_rsa"
}

//variable "instances_count" {
//  description = "How many controllers"
//  default = 2
//}

variable "node_names" {
  type = list(string)
  default = ["kmaster", "kworker"]
}