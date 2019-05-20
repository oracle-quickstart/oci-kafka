# This is an example of how to use the terraform_oci_kafka module to deploy a kafka cluster in OCI by using
# existing VCN, Security list and Subnets.

# PROVIDER
provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

# DATASOURCE
# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count    = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}

# DEPLOY THE kafka CLUSTER
module "kafkas" {
  source                           = "../../"
  compartment_ocid                 = "${var.compartment_ocid}"
  ads                              = "${data.template_file.ad_names.*.rendered}"
  subnet_ids                       = "${var.subnet_ids}"
  image_id                         = "${var.image_id[var.region]}"
  zookeeper_client_port            = "12181"
  zookeeper_internal_port          = "12888"
  zookeeper_poll_port              = "13888"
  kafka_client_port                = "19092"
  number_of_instance               = "3"
  ssh_authorized_keys              = "${var.ssh_authorized_keys}"
  ssh_private_key                  = "${var.ssh_private_key}"

}

# VARIABLES
variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_authorized_keys" {}
variable "ssh_private_key" {}

variable "subnet_ids" {
  type = "list"
}

variable "image_id" {
  type = "map"

  # Oracle-provided image "Oracle-Linux-7.5-2018.06.14-0"
  # See https://docs.us-phoenix-1.oraclecloud.com/images/
  default = {
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaxyc7rpmh3v4yyuxcdjndofxuuus4iwd7a7wjc63u2ykycojr5djq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaazq7xlunevyn3cf4wppcx2j53eb26pnnc4ukqtfj4tbjjcklnhpaa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7qdjjqlvryzxx4i2zs5si53edgmwr2ldn22whv5wv34fc3sdsova"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaas5vonrmseff5fljdmpffffqotcqdrxkbsctotrmqfrnbjd6wwsfq"
  }
}
