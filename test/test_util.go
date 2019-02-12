package test

import (
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
)

const DB_NAME = "testdb"
const DB_USER = "testuser"
const DB_PASS = "testpassword"

const KEY_REGION = "region"
const KEY_PROJECT = "project"

const MYSQL_VERSION = "MYSQL_5_7"

const OUTPUT_MASTER_IP_ADDRESSES = "master_ip_addresses"
const OUTPUT_MASTER_INSTANCE_NAME = "master_instance_name"
const OUTPUT_FAILOVER_INSTANCE_NAME = "failover_instance_name"
const OUTPUT_MASTER_PROXY_CONNECTION = "master_proxy_connection"
const OUTPUT_FAILOVER_PROXY_CONNECTION = "failover_proxy_connection"
const OUTPUT_MASTER_PUBLIC_IP = "master_public_ip"
const OUTPUT_MASTER_PRIVATE_IP = "master_private_ip"
const OUTPUT_MASTER_CA_CERT = "master_ca_cert"
const OUTPUT_CLIENT_CA_CERT = "client_ca_cert"
const OUTPUT_CLIENT_PRIVATE_KEY = "client_private_key"

const OUTPUT_DB_NAME = "db_name"

const MYSQL_CREATE_TEST_TABLE_WITH_AUTO_INCREMENT_STATEMENT = "CREATE TABLE IF NOT EXISTS test (id int NOT NULL AUTO_INCREMENT, name varchar(10) NOT NULL, PRIMARY KEY (ID))"
const MYSQL_EMPTY_TEST_TABLE_STATEMENT = "DELETE FROM test"
const MYSQL_INSERT_TEST_ROW = "INSERT INTO test(name) VALUES(?)"

func getRandomRegion(t *testing.T, projectID string) string {
	//approvedRegions := []string{"europe-north1", "europe-west1", "europe-west2", "europe-west3", "us-central1", "us-east1", "us-west1"}
	approvedRegions := []string{"europe-north1"}
	return gcp.GetRandomRegion(t, projectID, approvedRegions, []string{})
}

func createTerratestOptionsForMySql(projectId string, region string, exampleDir string, namePrefix string) *terraform.Options {

	terratestOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: exampleDir,
		Vars: map[string]interface{}{
			"region":               region,
			"project":              projectId,
			"name_prefix":          namePrefix,
			"mysql_version":        MYSQL_VERSION,
			"db_name":              DB_NAME,
			"master_user_name":     DB_USER,
			"master_user_password": DB_PASS,
		},
	}

	return terratestOptions
}

func createTerratestOptionsForClientCert(projectId string, region string, exampleDir string, commonName string, instanceName string) *terraform.Options {

	terratestOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: exampleDir,
		Vars: map[string]interface{}{
			"region":                 region,
			"project":                projectId,
			"common_name":            commonName,
			"database_instance_name": instanceName,
		},
	}

	return terratestOptions
}
