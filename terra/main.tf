provider "libvirt" {
  uri = "qemu+ssh://dave/system?socket=/var/run/libvirt/libvirt-sock"
}

resource "libvirt_pool" "kube" {
  name = "kube"
  type = "dir"
  path = var.libvirt_disk_path
}

resource "libvirt_volume" "ubuntu-template-volume" {
  name = "ubuntu-template-volume"
  pool = libvirt_pool.kube.name
  //  source = "http://cloud-images.ubuntu.com/releases/focal/release-20210510/ubuntu-20.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "controller-volume" {
  //  base_volume_id = libvirt_volume.ubuntu-template-volume.id
  base_volume_name = "ubuntu-template-volume"
  for_each = toset(var.node_names)
  name = each.key
  size = 40000000000

  pool = libvirt_pool.kube.name
  format = "qcow2"
}

data "template_file" "image_config" {
  for_each = toset(var.node_names)
  vars = {
    HOSTNAME = each.key,
    SSH_USER = var.ssh_username
  }
  template = file("${path.module}/config/cloud_init.yml")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = toset(var.node_names)
  name = "commoninit-${each.key}.iso"
  user_data = data.template_file.image_config[each.key].rendered
  pool = libvirt_pool.kube.name

}

resource "libvirt_domain" "kube-cluster" {
  for_each = toset(var.node_names)
  name = each.key
  memory = "8192"
  vcpu = 8

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

  network_interface {
    network_id = libvirt_network.kube-network.id
    wait_for_lease = true
    hostname = each.key
  }

  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.controller-volume[each.key].id
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = self.network_interface.0.addresses.0
    private_key = file(var.ssh_private_key)
    bastion_host = "green.mhs.by"
    bastion_port = 202
    bastion_user = "ubuntu"
    bastion_private_key = file(var.ssh_private_key)
    timeout = "2m"
  }


  provisioner "remote-exec" {
    inline = [
      "echo 'Hello World'",
      "echo $(hostname)"
    ]
  }


  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -u ${var.ssh_username} --private-key ${var.ssh_private_key} -i nginx.ini ansible/playbook.yml
      EOT
  }
}

data "template_file" "inventory_template" {
  template = file("../ansible/kube.inventory.template")
  vars = {
    nodes = join("\n", toset([
    for node in libvirt_domain.kube-cluster : node.network_interface[0].addresses[0]
    ]))
    masters = libvirt_domain.kube-cluster["kmaster"].network_interface[0].addresses[0]
    workers = libvirt_domain.kube-cluster["kworker"].network_interface[0].addresses[0]
  }
}

resource "local_file" "inventory" {
  content = data.template_file.inventory_template.rendered
  filename = "./ansible/kube.inventory"
  directory_permission = 0755
  file_permission = 0755
}

