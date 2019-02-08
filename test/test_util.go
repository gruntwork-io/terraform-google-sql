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

const OUTPUT_IP_ADDRESSES = "ip_addresses"
const OUTPUT_INSTANCE_NAME = "instance_name"
const OUTPUT_PROXY_CONNECTION = "proxy_connection"
const OUTPUT_DB_NAME = "db_name"
const OUTPUT_PUBLIC_IP = "public_ip"
const OUTPUT_PRIVATE_IP = "private_ip"

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
