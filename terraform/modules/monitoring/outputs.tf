output "external_ip_address_monitoring" {
  value = yandex_compute_instance.monitoring[*].network_interface.0.nat_ip_address
}
