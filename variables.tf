variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "dns_label" {
  description = "Allows assignment of DNS hostname when launching an Instance. "
  default     = ""
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default     = ""
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "number_of_instance" {
  description = "The number of instance(s) to create. "
}

variable "ads" {
  description = "The Availability Domain for instances. "
  default     = []
}

variable "subnet_ids" {
  description = "The OCID of the subnet to create the VNIC in. "
  default     = []
}

variable "display_name" {
  description = "The name of the instances. "
  default     = ""
}

variable "image_id" {
  description = "The OCID of an image for a instance to use. "
  default     = ""
}

variable "shape" {
  description = "Instance shape to use for instance. "
  default     = "VM.Standard2.1"
}

variable "user_data" {
  description = "Provide your own base64-encoded data to be used by Cloud-Init to run custom scripts or provide custom Cloud-Init configuration for master instance. "
  default     = ""
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

variable "bastion_host" {
  description = "The bastion host IP."
}

variable "bastion_user" {
  description = "The SSH user to connect to the bastion host."
  default     = "opc"
}

variable "bastion_private_key" {
  description = "The private key path to access the bastion host."
}
