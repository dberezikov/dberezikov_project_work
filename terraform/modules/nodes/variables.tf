variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}
variable "os_release" {
  description = "Version of OS"
}
variable "count_of_node_instances" {
  description = "Count of instances"
  default     = 1
}
variable "core_fraction" {
  description = "Core fraction"
}
variable "cores_node" {
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
variable "subnet_id" {
  description = "Subnet"
}

