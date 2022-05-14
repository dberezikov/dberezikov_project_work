terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
}

data "yandex_compute_image" "ubuntu-image" {
  family = var.os_release
}

resource "yandex_compute_instance" "node" {
  name     = "node${count.index}" 
  hostname = "node${count.index}"
  count    = var.count_of_instances

  resources {
    core_fraction = var.core_fraction
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-image.image_id
      size     = var.boot_disk_size
      type     = var.boot_disk_type
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    private_key = file(var.private_key_path)
  }

}

locals {
  names = yandex_compute_instance.node.*.name
  ips   = yandex_compute_instance.node.*.network_interface.0.nat_ip_address
}

# Invetrory for ansible
resource "local_file" "inventory" {
  content = templatefile("inventory.tpl",
    {
      names = local.names,
      addrs = local.ips,
    }
  )
  filename = "../ansible/inventory.ini"
}
