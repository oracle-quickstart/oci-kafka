# DEPLOY THE Kafka CLUSTER
module "kafkas" {
  source                           = "../../"
  compartment_ocid                 = "${var.compartment_ocid}"
  ads                              = "${data.template_file.ad_names.*.rendered}"
  subnet_ids                       = "${split(",",join(",", oci_core_subnet.SubnetAD.*.id))}"
  image_id                         = "${var.image_id[var.region]}"
  zookeeper_client_port            = "${var.zookeeper_client_port}"
  zookeeper_internal_port          = "${var.zookeeper_internal_port}"
  zookeeper_poll_port              = "${var.zookeeper_poll_port}"
  kafka_client_port                = "${var.kafka_client_port}"
  number_of_instance               = "${var.number_of_instance}"
  ssh_authorized_keys              = "${var.ssh_authorized_keys}"
  ssh_private_key                  = "${var.ssh_private_key}"
  bastion_host         = "${var.bastion_public_ip}"
  bastion_user         = "${var.bastion_user}"
  bastion_private_key  = "${var.bastion_private_key}"
}
