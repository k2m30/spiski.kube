provider "libvirt" {
  uri = "qemu+ssh://dave/system?socket=/var/run/libvirt/libvirt-sock"
}

resource "libvirt_pool" "kube" {
  name = "kube"
  type = "dir"
  path = var.libvirt_disk_path
}

resource "libvirt_volume" "ubuntu-volume" {
  count = var.instances_count
  name = "ubuntu-volume-${count.index}"
  pool = libvirt_pool.kube.name
  source = "http://cloud-images.ubuntu.com/releases/bionic/release-20191008/ubuntu-18.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

data "template_file" "user_data" {
  count = var.instances_count
  vars = {
    HOSTNAME = "controller-${count.index}"
  }
  template = file("${path.module}/config/cloud_init.yml")
}

data "template_file" "network_config" {
  template = file("${path.module}/config/network_config.yml")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.instances_count
  name = "commoninit-${count.index}.iso"
  user_data = data.template_file.user_data[count.index].rendered
  network_config = data.template_file.network_config.rendered
  pool = libvirt_pool.kube.name

}

resource "libvirt_domain" "kube-cluster" {
  count = var.instances_count
  name = "controller-${count.index}"
  memory = "512"
  vcpu = 1

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    network_name = "default"
    wait_for_lease = true
//    hostname = "controller-${count.index}"
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
    volume_id = libvirt_volume.ubuntu-volume[count.index].id
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
}

