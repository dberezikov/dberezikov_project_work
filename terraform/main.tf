terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
}

provider "yandex" {
  token                    = var.token
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

module "node" {
  source                   = "./modules/nodes"
  public_key_path          = var.public_key_path
  private_key_path         = var.private_key_path
  subnet_id                = var.subnet_id
  count_of_instances       = var.count_of_instances 
  os_release               = var.os_release
  core_fraction            = var.core_fraction
  cores                    = var.cores
  memory                   = var.memory
  boot_disk_size           = var.boot_disk_size
  boot_disk_type           = var.boot_disk_type  
}

resource "null_resource" "ansible" {
  depends_on = [module.node]
  provisioner "local-exec" {
    command = "sleep 30"
  }
  provisioner "local-exec" {
    command     = "ansible-playbook playbook.yml"
    working_dir = "../ansible"
  }
}
