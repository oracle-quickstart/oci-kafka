package test

type Inputs struct {
	TenancyOcid       string `json:"tenancy_ocid"`
	CompartmentOcid   string `json:"compartment_ocid"`
	UserOcid          string `json:"user_ocid"`
	Region            string `json:"region"`
	Fingerprint       string `json:"fingerprint"`
	PrivateKeyPath    string `json:"private_key_path"`
	SSHAuthorizedKeys string `json:"ssh_authorized_keys"`
	SSHPrivateKey     string `json:"ssh_private_key"`
}
