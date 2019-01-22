############################################
# Create VCN
############################################
resource "oci_core_virtual_network" "KafkaVCN" {
  cidr_block     = "${lookup(var.network_cidrs, "VCN-CIDR")}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "KafkaVCN"
  dns_label      = "kafka"
}

############################################
# Create Internet Gateways
############################################
resource "oci_core_internet_gateway" "KafkaIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}KafkaIG"
  vcn_id         = "${oci_core_virtual_network.KafkaVCN.id}"
}

############################################
# Create NAT Gateway
############################################
resource "oci_core_nat_gateway" "KafkaNG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.KafkaVCN.id}"
  display_name   = "KafkaNG"
}


############################################
# Create Route Table
############################################
resource "oci_core_route_table" "KafkaPublicRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.KafkaVCN.id}"
  display_name   = "${var.label_prefix}KafkaPublicRT"

  route_rules {
    cidr_block = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    # Internet Gateway route target for instances on public subnets
    network_entity_id = "${oci_core_internet_gateway.KafkaIG.id}"
  }
}

resource "oci_core_route_table" "KafkaPrivateRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.KafkaVCN.id}"
  display_name   = "KafkaPrivateRT"

  route_rules {
    cidr_block       = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    # Internet Gateway route target for instances on public subnets
    network_entity_id = "${oci_core_nat_gateway.KafkaNG.id}"
  }
}

############################################
# Create Security List
############################################
resource "oci_core_security_list" "KafkaPrivate" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}KafkaPrivate"
  vcn_id         = "${oci_core_virtual_network.KafkaVCN.id}"

  egress_security_rules = [{
    destination = "0.0.0.0/0"
    protocol    = "all"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  },
    {
      tcp_options {
        "max" = "${var.zookeeper_client_port}"
        "min" = "${var.zookeeper_client_port}"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "${var.zookeeper_internal_port}"
        "min" = "${var.zookeeper_internal_port}"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "${var.zookeeper_poll_port}"
        "min" = "${var.zookeeper_poll_port}"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "${var.kafka_client_port}"
        "min" = "${var.kafka_client_port}"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
  ]
}

resource "oci_core_security_list" "bastion" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "bastion"
  vcn_id         = "${oci_core_virtual_network.KafkaVCN.id}"

  egress_security_rules = [{
    protocol    = "6"
    destination =  "${lookup(var.network_cidrs, "VCN-CIDR")}"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }]
}

resource "oci_core_security_list" "nat" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "nat"
  vcn_id         = "${oci_core_virtual_network.KafkaVCN.id}"

  egress_security_rules = [{
    protocol    = "6"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [{
    protocol = "6"
    source   =  "${lookup(var.network_cidrs, "VCN-CIDR")}"
  }]
}

############################################
# Create Subnet
############################################
resource "oci_core_subnet" "SubnetAD" {
  count               = "${length(data.template_file.ad_names.*.rendered)}"
  availability_domain = "${data.template_file.ad_names.*.rendered[count.index]}"
  cidr_block          = "${lookup(var.network_cidrs, "SubnetAD${count.index+1}")}"
  display_name        = "${var.label_prefix}SubnetAD${count.index+1}"
  dns_label           = "ad${count.index+1}"
  security_list_ids   = ["${oci_core_security_list.KafkaPrivate.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.KafkaVCN.id}"
  route_table_id      = "${oci_core_route_table.KafkaPrivateRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.KafkaVCN.default_dhcp_options_id}"
}

############################################
# Create Bastion Subnet
############################################
resource "oci_core_subnet" "bastion" {
  availability_domain = "${data.template_file.ad_names.*.rendered[var.bastion_ad_index]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "BastionAD${var.bastion_ad_index+1}"
  cidr_block          = "${cidrsubnet(local.bastion_subnet_prefix, 3, 0)}"
  security_list_ids   = ["${oci_core_security_list.bastion.id}"]
  vcn_id              = "${oci_core_virtual_network.KafkaVCN.id}"
  route_table_id      = "${oci_core_route_table.KafkaPublicRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.KafkaVCN.default_dhcp_options_id}"
}
