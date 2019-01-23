resource "oci_core_instance" "bastion" {
  availability_domain = "${data.template_file.ad_names.*.rendered[var.bastion_ad_index]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.bastion_display_name}${var.bastion_ad_index+1}"
  shape               = "${var.bastion_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.bastion.id}"
    assign_public_ip = true
  }

  metadata {
    ssh_authorized_keys = "${file("${var.bastion_authorized_keys}")}"
  }

  source_details {
    source_id   = "${var.image_id[var.region]}"
    source_type = "image"
  }
}


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
  bastion_host         = "${oci_core_instance.bastion.public_ip}"
  bastion_user         = "${var.bastion_user}"
  bastion_private_key  = "${var.bastion_private_key}"
}
