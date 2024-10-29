output "jenkins_url" {
  description = "URL do Jenkins"
  value = "http://${google_compute_instance.my_instance.network_interface.0.access_config.0.nat_ip}:8080/"
}

output "sonarqube_url" {
  description = "URL do Sonarqube"
  value = "http://${google_compute_instance.my_instance.network_interface.0.access_config.0.nat_ip}:9000/"
}