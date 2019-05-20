## Run go test to test the example in this module
This example shows how to run go test to test a terraform module.

### Using this test example
1. Download this module(terraform-oci-kafka) and put it in the go path directory of your machine.
2. Update inputs_config.json with the required information.

### Run go test  
Download or update the specified code package and its dependencies from Internet:
```
$ cd test
$ go get
```
Run go test:
```
$ GOCACHE=off  go test -timeout 60m -v -run TestModuleKafkaExample2
```

Test Oracle Cloud Infrastructure Kafka Terraform Module

1.Install Terraform and make sure it's on your PATH.

2.Install Golang and make sure this code is checked out into your GOPATH.

3.cd test

4.go test -v -run TestTerraformKafkadeployExample

Note:

Go's package testing has a default timeout of 10 minutes, after which it forcibly kills your tests (even your cleanup code won't run!). It's not uncommon for infrastructure tests to take longer than 10 minutes, so you'll want to increase this timeout:

go test -v -run TestTerraformKafkadeployExample -timeout 30m
