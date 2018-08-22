############################################
# Create VCN
############################################
resource "oci_core_virtual_network" "VCN" {
  cidr_block     = "${lookup(var.network_cidrs, "VCN-CIDR")}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "VCN"
  dns_label      = "ocidns"
}

############################################
# Create Internet Gateways
############################################
resource "oci_core_internet_gateway" "IG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}IG"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"
}

############################################
# Create Route Table
############################################
resource "oci_core_route_table" "RT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"
  display_name   = "${var.label_prefix}RouteTable"

  route_rules {
    cidr_block = "0.0.0.0/0"

    # Internet Gateway route target for instances on public subnets
    network_entity_id = "${oci_core_internet_gateway.IG.id}"
  }
}

############################################
# Create Security List
############################################
resource "oci_core_security_list" "SecurityList" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}SecurityList"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"

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

############################################
# Create Subnet
############################################
resource "oci_core_subnet" "SubnetAD" {
  count               = "${length(data.template_file.ad_names.*.rendered)}"
  availability_domain = "${data.template_file.ad_names.*.rendered[count.index]}"
  cidr_block          = "${lookup(var.network_cidrs, "SubnetAD${count.index+1}")}"
  display_name        = "${var.label_prefix}SubnetAD${count.index+1}"
  dns_label           = "ad${count.index+1}"
  security_list_ids   = ["${oci_core_security_list.SecurityList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.VCN.id}"
  route_table_id      = "${oci_core_route_table.RT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
}
