Create VCN and Deploy Kafka Cluster

This example creates a VCN in Oracle Cloud Infrastructure including default route table, DHCP options, security list and subnets from scratch, then use terraform_oci_kafka module to deploy a Kafka cluster.
Using this example

* Update terraform.tfvars with the required information
* Update variables.tf with your instance options

Deploy the cluster

Initialize Terraform:

$ terraform init

View what Terraform plans do before actually doing it:

$ terraform plan -var-file /path/of/file/terraform.tfvars

Use Terraform to Provision resources and Kafka cluster on Oracle Cloud Infrastructure:

$ terraform apply -var-file /path/of/file/terraform.tfvars

Test connection to database

Check the elasticsearch cluster nodes info

curl -XGET 'http://${es_master_public_ip}:9200/_cat/nodes'

Check the elasticsearch running status

curl -XGET 'http://${es_master_public_ip}:9200'

Check the ELK cluster health status

curl -XGET 'http://${es_master_public_ip}:9200/_cluster/health?pretty'

Check if elasticsearch received the data from logstash

curl -XGET 'http://${es_master_public_ip}:9200/_search'

Test connection to database

Check the logstash could write log to elasticsearch cluster nodes

curl -XGET 'http://${es_master_public_ip}:9200/_cat/indices?v'

Check the kibana running status

curl -XGET 'http://${kibana_public_ip}:5601'

