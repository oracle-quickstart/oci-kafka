output "ids" {
  value = ["${oci_core_instance.TFKafkaNode.*.id}"]
}

output "private_ips" {
  value = ["${oci_core_instance.TFKafkaNode.*.private_ip}"]
}

output "public_ips" {
  value = ["${oci_core_instance.TFKafkaNode.*.public_ip}"]
}

output "display_names" {
  value = ["${oci_core_instance.TFKafkaNode.*.display_name}"]
}
