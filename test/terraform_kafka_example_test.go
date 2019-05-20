package test

import (
	"strings"
	"testing"

	"terraform-module-test-lib"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTerraformKafkadeployExample(t *testing.T) {
	terraform_dir := "../examples/quick_start/"
	terraform_options := configureTerraformOptions(t, terraform_dir)
	test_structure.RunTestStage(t, "init", func() {
		logger.Log(t, "terraform init ...")
		terraform.Init(t, terraform_options)
	})
	defer test_structure.RunTestStage(t, "destroy", func() {
		logger.Log(t, "terraform destroy  ...")
		terraform.Destroy(t, terraform_options)
	})
	test_structure.RunTestStage(t, "apply", func() {
		logger.Log(t, "terraform apply ...")
		terraform.Apply(t, terraform_options)
	})
	test_structure.RunTestStage(t, "validate", func() {
		logger.Log(t, "Verfiying  ...")
		validateCreateTopic(t, terraform_options)
		validateProduceConsumeMessage(t, terraform_options)

	})
}
func configureTerraformOptions(t *testing.T, terraform_dir string) *terraform.Options {
	var vars Inputs
	test_helper.GetConfig("inputs_config.json", &vars)
	terraformOptions := &terraform.Options{
		TerraformDir: terraform_dir,
		Vars: map[string]interface{}{
			"tenancy_ocid":            vars.Tenancy_ocid,
			"user_ocid":               vars.User_ocid,
			"fingerprint":             vars.Fingerprint,
			"region":                  vars.Region,
			"compartment_ocid":        vars.Compartment_ocid,
			"private_key_path":        vars.Private_key_path,
			"ssh_authorized_keys":     vars.Ssh_authorized_keys,
			"ssh_private_key":         vars.Ssh_private_key,
			"bastion_authorized_keys": vars.Bastion_authorized_keys,
			"bastion_private_key":     vars.Bastion_private_key,
		},
	}
	return terraformOptions
}
func validateCreateTopic(t *testing.T, terraform_options *terraform.Options) {
	// build key pair for ssh connections
	ssh_public_key_path := terraform_options.Vars["ssh_authorized_keys"].(string)
	ssh_private_key_path := terraform_options.Vars["ssh_private_key"].(string)
	key_pair, err := test_helper.GetKeyPairFromFiles(ssh_public_key_path, ssh_private_key_path)
	if err != nil {
		assert.NotNil(t, key_pair)
	}
	bastion_public_ip := terraform.Output(t, terraform_options, "bastion_public_ip")
	kafka_private_ips := terraform.Output(t, terraform_options, "kafka_private_ips")
	private_ips := strings.Split(kafka_private_ips, ",")
	ip := strings.TrimSpace(private_ips[0])
	command := "./opt/kafka/kafka_2.12-1.1.0/bin/kafka-topics.sh --create --zookeeper localhost:12181 --replication-factor 2 --partitions 1 --topic test"
	result := test_helper.SSHToPrivateHost(t, bastion_public_ip, ip, "opc", key_pair, command)
	assert.True(t, strings.Contains(result, "Created topic \"test\""))
}

func validateProduceConsumeMessage(t *testing.T, terraform_options *terraform.Options) {
	// build key pair for ssh connections
	ssh_public_key_path := terraform_options.Vars["ssh_authorized_keys"].(string)
	ssh_private_key_path := terraform_options.Vars["ssh_private_key"].(string)
	key_pair, err := test_helper.GetKeyPairFromFiles(ssh_public_key_path, ssh_private_key_path)
	if err != nil {
		assert.NotNil(t, key_pair)
	}
	bastion_public_ip := terraform.Output(t, terraform_options, "bastion_public_ip")
	kafka_private_ips := terraform.Output(t, terraform_options, "kafka_private_ips")
	private_ips := strings.Split(kafka_private_ips, ",")
	ip1 := strings.TrimSpace(private_ips[1])
	ip2 := strings.TrimSpace(private_ips[2])
	produceCommand := "echo 'Test producer,consumer' > test.txt &&  ./opt/kafka/kafka_2.12-1.1.0/bin/kafka-console-producer.sh --broker-list localhost:19092 --topic test < test.txt"
	consumeCommand := "./opt/kafka/kafka_2.12-1.1.0/bin//kafka-console-consumer.sh --zookeeper localhost:12181 --topic test --from-beginning   --max-messages 1"
	test_helper.SSHToPrivateHost(t, bastion_public_ip, ip1, "opc", key_pair, produceCommand)
	result := test_helper.SSHToPrivateHost(t, bastion_public_ip, ip2, "opc", key_pair, consumeCommand)
	assert.True(t, strings.Contains(result, "Test producer,consumer"))
}
