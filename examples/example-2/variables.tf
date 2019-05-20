variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_authorized_keys" {}
variable "ssh_private_key" {}


variable "network_cidrs" {
  type = "map"

  default = {
    VCN-CIDR  = "10.0.0.0/16"
    SubnetAD1 = "10.0.30.0/24"
    SubnetAD2 = "10.0.31.0/24"
    SubnetAD3 = "10.0.32.0/24"
  }
}

variable "label_prefix" {
  default = ""
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

variable "zookeeper_client_port" {
  default     = "12181"
}

variable "zookeeper_internal_port" {
  default     = "12888"
}

variable "zookeeper_poll_port" {
  default     = "13888"
}

variable "kafka_client_port" {
  default     = "19092"
}
