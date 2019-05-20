package test

import (
	"strings"
	"terraform-module-test-lib"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestModuleKafkaExample2(t *testing.T) {
	terraformDir := "../examples/example-2"
	terraformOptions := configureTerraformOptions(t, terraformDir)

	test_structure.RunTestStage(t, "init", func() {
		logger.Log(t, "terraform init ...")
		terraform.Init(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "apply", func() {
		logger.Log(t, "terraform apply instance ...")
		terraform.Apply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		logger.Log(t, "Verfiying  ...")
		validateSolution(t, terraformOptions)
	})

	defer test_structure.RunTestStage(t, "destroy", func() {
		logger.Log(t, "terraform destroy instance ...")
		terraform.Destroy(t, terraformOptions)
	})
}

func configureTerraformOptions(t *testing.T, terraformDir string) *terraform.Options {
	var vars Inputs
	err := test_helper.GetConfig("inputs_config.json", &vars)
	if err != nil {
		logger.Logf(t, err.Error())
		t.Fail()
	}
	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"tenancy_ocid":        vars.TenancyOcid,
			"user_ocid":           vars.UserOcid,
			"fingerprint":         vars.Fingerprint,
			"region":              vars.Region,
			"compartment_ocid":    vars.CompartmentOcid,
			"private_key_path":    vars.PrivateKeyPath,
			"ssh_authorized_keys": vars.SSHAuthorizedKeys,
			"ssh_private_key":     vars.SSHPrivateKey,
		},
	}
	return terraformOptions
}

func validateSolution(t *testing.T, terraformOptions *terraform.Options) {
	// build key pair for ssh connections
	sshPublicKeyPath := terraformOptions.Vars["ssh_authorized_keys"].(string)
	sshPrivateKeyPath := terraformOptions.Vars["ssh_private_key"].(string)
	keyPair, err := test_helper.GetKeyPairFromFiles(sshPublicKeyPath, sshPrivateKeyPath)
	if err != nil {
		assert.NotNil(t, keyPair)
	}
	validateBySSHToKafkaHost(t, terraformOptions, keyPair)
}

func validateBySSHToKafkaHost(t *testing.T, terraformOptions *terraform.Options, keyPair *ssh.KeyPair) {
	zooKeeperVerifyCommand := "/home/opc/opt/zookeeper/zookeeper-3.4.10/bin/zkServer.sh status"
	kafkaVerifyCommand := "jps | grep Kafka"
	kafkaPublicIps := terraform.Output(t, terraformOptions, "kafka_public_ips")
	publicIps := strings.Split(kafkaPublicIps, ",")
	for i := 0; i < len(publicIps); i++ {
		ip := strings.TrimSpace(publicIps[i])
		result := test_helper.SSHToHost(t, ip, "opc", keyPair, zooKeeperVerifyCommand)
		assert.True(t, strings.Contains(result, "Mode:"))
		result = test_helper.SSHToHost(t, ip, "opc", keyPair, kafkaVerifyCommand)
		assert.True(t, strings.Contains(result, "Kafka"))
	}
}
