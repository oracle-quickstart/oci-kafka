data "template_file" "kafka_setup" {
  template = "${file("${path.module}/scripts/setup.sh")}"

  vars {
    zookeeper_client_port          = "${var.zookeeper_client_port}"
    zookeeper_internal_port        = "${var.zookeeper_internal_port}"
    zookeeper_poll_port            = "${var.zookeeper_poll_port}"
    kafka_client_port              = "${var.kafka_client_port}"
    number_of_kafka                = "${var.number_of_kafka}"

  }
}


###########################################
# kafka instance
############################################
resource "oci_core_instance" "TFKafkaNode" {
  count               = "${var.number_of_kafka}"
  availability_domain = "${var.availability_domains[count.index%length(var.availability_domains)]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.kafka_display_name}${count.index + 1}"
  shape               = "${var.shape}"

  create_vnic_details {
    subnet_id        = "${var.subnet_ids[count.index%length(var.subnet_ids)]}"
    display_name     = "${var.kafka_display_name}${count.index + 1}"
    assign_public_ip = "${var.assign_public_ip}"
  }

  metadata {
    ssh_authorized_keys = "${file("${var.ssh_authorized_keys}")}"
  }

  source_details {
    source_id   = "${var.image_id}"
    source_type = "image"
  }


  provisioner "file" {
    connection = {
      host        = "${self.private_ip}"
      agent       = false
      timeout     = "5m"
      user        = "${var.vm_user}"
      private_key = "${file("${var.ssh_private_key}")}"
      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    content     = "${data.template_file.kafka_setup.rendered}"
    destination = "~/setup.sh"
  }

  provisioner "remote-exec" {
    connection = {
      host        = "${self.private_ip}"
      agent       = false
      timeout     = "5m"
      user        = "${var.vm_user}"
      private_key = "${file("${var.ssh_private_key}")}"
      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    inline = [
      "chmod +x ~/setup.sh",
      "~/setup.sh ${self.display_name} >> /home/opc/kafka_setup.log",
    ]
  }
}
