variable "token" {
  description = "OAuth"
}
variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  default = "ru-central1-a"
}
variable "region" {
  description = "Region"
  default = "ru-central1"
}
variable "os_release" {
  description = "Version of OS"
}
variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}
variable "subnet_id" {
  description = "Subnet"
}
variable "service_account_key_file" {
  description = "key .json"
}
variable "count_of_node_instances" {
  description = "Count of instances"
  default     = 1
}
variable "count_of_mon_instances" {
  description = "Count of instances"
  default     = 1
}
variable "core_fraction" {
  description = "Core fraction"
}
variable "cores_node" {
  description = "Count of cores"
}
variable "cores_mon" {
  description = "Count of cores"
}
variable "boot_disk_size" {
  description = "Boot disk size"
}
variable "boot_disk_type" {
  description = "Boot disk type"
}
variable "memory_node" {
  description = "Count of memory"
}
variable "memory_mon" {
  description = "Count of memory"
}
