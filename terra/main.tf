provider "libvirt" {
  uri = "qemu+ssh://dave/system?socket=/var/run/libvirt/libvirt-sock"
}

resource "libvirt_pool" "kube" {
  name = "kube"
  type = "dir"
  path = var.libvirt_disk_path
}

resource "libvirt_volume" "ubuntu-qcow2" {
  name = "ubuntu-qcow2"
  pool = "default"
  source = "http://cloud-images.ubuntu.com/releases/bionic/release-20191008/ubuntu-18.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/config/cloud_init.yml")
}

data "template_file" "network_config" {
  template = file("${path.module}/config/network_config.yml")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool = "default"

}

resource "libvirt_domain" "domain-ubuntu" {
  name = var.vm_hostname
  memory = "512"
  vcpu = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
    wait_for_lease = true
    hostname = var.vm_hostname
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
    volume_id = libvirt_volume.ubuntu-qcow2.id
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello World'"
    ]

    connection {
      type = "ssh"
      user = var.ssh_username
      host = libvirt_domain.domain-ubuntu.network_interface[0].addresses[0]
      private_key = file(var.ssh_private_key)
      bastion_host = "green.mhs.by"
      bastion_port = 202
      bastion_user = "ubuntu"
      bastion_private_key = file(var.ssh_private_key)
      timeout = "2m"
    }
  }
}