output "external_ip_address_ms" {
  value = yandex_compute_instance.ms[*].network_interface.0.nat_ip_address
}
