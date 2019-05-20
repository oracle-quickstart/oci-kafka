# Kafka Instances
############################################
module "kafka-instance" {
  source               = "./modules/kafka"
  number_of_kafka      = "${var.number_of_instance}"
  availability_domains = "${var.ads}"
  compartment_ocid     = "${var.compartment_ocid}"
  kafka_display_name   = "${var.display_name}"
  image_id             = "${var.image_id}"
  shape                = "${var.shape}"
  subnet_ids           = "${var.subnet_ids}"
  zookeeper_client_port             = "${var.zookeeper_client_port}"
  zookeeper_internal_port           = "${var.zookeeper_internal_port}"
  zookeeper_poll_port               = "${var.zookeeper_poll_port}"
  kafka_client_port                 = "${var.kafka_client_port}"


  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"

  bastion_host          = "${var.bastion_host}"
  bastion_user          = "${var.bastion_user}"
  bastion_private_key   = "${var.bastion_private_key}"

}

locals {
  public_ips           = "${module.kafka-instance.public_ips}"
  public_ips_list_tmp  = "${join(" ", "${local.public_ips}")}"
  public_ips_list_tmp_str  = "${format("%s", "${local.public_ips_list_tmp}")}"

  private_ips           = "${module.kafka-instance.private_ips}"
  private_ips_list_tmp  = "${join(" ", "${local.private_ips}")}"
  private_ips_list_tmp_str  = "${format("%s", "${local.private_ips_list_tmp}")}"

  display_names           = "${module.kafka-instance.display_names}"
  display_names_list_tmp  = "${join(" ", "${local.display_names}")}"
  display_names_list_tmp_str  = "${format("%s", "${local.display_names_list_tmp}")}"


}

data "template_file" "setup_kafka_cluster" {
  template = "${file("../../modules/kafka/scripts/cluster_setup.sh")}"

  vars {
    cluster_ip_list    = "${local.private_ips_list_tmp_str}"
    cluster_display_name_list    = "${local.display_names_list_tmp_str}"
    number                       = "${var.number_of_instance}"
  }
}



############################################
# config kafka cluster
############################################
resource "null_resource" "remote-exec-cluster-setup" {

  depends_on = ["module.kafka-instance"]
  count = "${var.number_of_instance}"
  provisioner "file" {
    connection = {
      host        = "${element(module.kafka-instance.private_ips, count.index)}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }
    content     = "${data.template_file.setup_kafka_cluster.rendered}"
    destination = "~/cluster_setup.sh"
  }

  provisioner "remote-exec" {
    connection = {
      host        = "${element(module.kafka-instance.private_ips, count.index)}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    inline = [
      "chmod +x ~/cluster_setup.sh",
      "sudo sed -i  's/abc//g' ~/cluster_setup.sh",
      "~/cluster_setup.sh >> /home/opc/cluster_setup.log ",
    ]
  }
}
