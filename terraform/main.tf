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
  count_of_node_instances  = var.count_of_node_instances 
  os_release               = var.os_release
  core_fraction            = var.core_fraction
  cores_node               = var.cores_node
  memory_node              = var.memory_node
  boot_disk_size           = var.boot_disk_size
  boot_disk_type           = var.boot_disk_type  
}

module "monitoring" {
  source                   = "./modules/monitoring"
  public_key_path          = var.public_key_path
  private_key_path         = var.private_key_path
  subnet_id                = var.subnet_id
  count_of_mon_instances   = var.count_of_mon_instances 
  os_release               = var.os_release
  core_fraction            = var.core_fraction
  cores_mon                = var.cores_mon
  memory_mon               = var.memory_mon
  boot_disk_size           = var.boot_disk_size
  boot_disk_type           = var.boot_disk_type  
  depends_on = [module.node]
}

resource "null_resource" "ansible" {
  depends_on = [module.monitoring] 
  provisioner "local-exec" {
    command = "sleep 60"
  }
  provisioner "local-exec" {
    command     = "ansible-playbook playbook.yml"
    working_dir = "../ansible"
  }
}
