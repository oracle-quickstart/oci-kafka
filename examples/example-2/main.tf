# DEPLOY THE Kafka CLUSTER
module "kafkas" {
  source                           = "../../"
  compartment_ocid                 = "${var.compartment_ocid}"
  ads                              = "${data.template_file.ad_names.*.rendered}"
  subnet_ids                       = "${split(",",join(",", oci_core_subnet.SubnetAD.*.id))}"
  image_id                         = "${var.image_id[var.region]}"
  zookeeper_client_port            = "12181"
  zookeeper_internal_port          = "12888"
  zookeeper_poll_port              = "13888"
  kafka_client_port                = "19092"
  number_of_instance               = "3"
  ssh_authorized_keys              = "${var.ssh_authorized_keys}"
  ssh_private_key                  = "${var.ssh_private_key}"
}
