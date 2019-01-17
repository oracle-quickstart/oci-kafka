package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
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
		validateSolution(t, terraform_options)

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
func validateSolution(t *testing.T, terraform_options *terraform.Options) {
	instanceText := "logstash"
	webIp := terraform.Output(t, terraform_options, "lb_public_ip")
	webUrl := "http://" + webIp + ":80"
	esUrl := "http://" + webIp + "/app/kibana#/management/elasticsearch/index_management/home"
	kibanaUrl := "http://" + webIp + "/app/kibana#/management/kibana/indices"
	http_helper.HttpGetWithCustomValidation(t, webUrl, func(statusCode int, body string) bool {
		return statusCode == 200
	})
	http_helper.HttpGetWithCustomValidation(t, esUrl, func(statusCode int, body string) bool {
		return statusCode == 200 && (strings.Contains(body, instanceText))
	})
	http_helper.HttpGetWithCustomValidation(t, kibanaUrl, func(statusCode int, body string) bool {
		return statusCode == 200 && (strings.Contains(body, instanceText))
	})
}
