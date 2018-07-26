output "kafka_instance_ids" {
  value = "${module.kafka-instance.ids}"
}

output "kafka_public_ips" {
  value = "${module.kafka-instance.public_ips}"
}

output "kafka_private_ips" {
  value = "${module.kafka-instance.private_ips}"
}

output "kafka_display_names" {
  value = "${module.kafka-instance.display_names}"
}
