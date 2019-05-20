variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "

}

variable "availability_domains" {
  description = "The Availability Domain of the instance. "
  default     = []
}

variable "kafka_display_name" {
  description = "The name of the kafka instance. "
  default     = ""
}

variable "subnet_ids" {
  description = "The OCID of the master subnet to create the VNIC in. "
  default     = []
}

variable "shape" {
  description = "Instance shape to use for elastic search instance. "
  default     = ""
}


variable "assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address. Default 'true' assigns a public IP address. "
  default     = true
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "image_id" {
  description = "The OCID of an image for an instance to use. "
  default     = ""
}

variable "number_of_kafka" {
  description = "The number of kafka instance(s) to create"
}

variable "cluster_name" {
  default     = "kafka_cluster"
}

variable "zookeeper_client_port" {
  description = "Zookeeper client port"

}

variable "zookeeper_internal_port" {
  description = "Zookeeper internal port"

}

variable "zookeeper_poll_port" {
  description = "Zookeeper poll port"

}

variable "kafka_client_port" {
  description = "Kafka client port"
  
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
variable "vm_user" {
  description = "The SSH user to connect to the slave host."
  default     = "opc"
}
