package test

import (
	"io/ioutil"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

const DB_NAME = "testdb"
const DB_USER = "testuser"
const DB_PASS = "testpassword"

const KEY_REGION = "region"
const KEY_PROJECT = "project"
const KEY_MASTER_ZONE = "masterZone"
const KEY_FAILOVER_REPLICA_ZONE = "failoverReplicaZone"
const KEY_READ_REPLICA_ZONE = "readReplicaZone"

const OUTPUT_MASTER_IP_ADDRESSES = "master_ip_addresses"
const OUTPUT_MASTER_INSTANCE_NAME = "master_instance_name"
const OUTPUT_FAILOVER_INSTANCE_NAME = "failover_instance_name"
const OUTPUT_MASTER_PROXY_CONNECTION = "master_proxy_connection"
const OUTPUT_FAILOVER_PROXY_CONNECTION = "failover_proxy_connection"
const OUTPUT_READ_REPLICA_PROXY_CONNECTIONS = "read_replica_proxy_connections"
const OUTPUT_READ_REPLICA_INSTANCE_NAMES = "read_replica_instance_names"
const OUTPUT_READ_REPLICA_PUBLIC_IPS = "read_replica_public_ips"
const OUTPUT_MASTER_PUBLIC_IP = "master_public_ip"
const OUTPUT_MASTER_PRIVATE_IP = "master_private_ip"
const OUTPUT_MASTER_CA_CERT = "master_ca_cert"
const OUTPUT_CLIENT_CA_CERT = "client_ca_cert"
const OUTPUT_CLIENT_PRIVATE_KEY = "client_private_key"

const OUTPUT_DB_NAME = "db_name"

const MYSQL_CREATE_TEST_TABLE_WITH_AUTO_INCREMENT_STATEMENT = "CREATE TABLE IF NOT EXISTS test (id int NOT NULL AUTO_INCREMENT, name varchar(10) NOT NULL, PRIMARY KEY (ID))"
const MYSQL_INSERT_TEST_ROW = "INSERT INTO test(name) VALUES(?)"

const SQL_EMPTY_TEST_TABLE_STATEMENT = "DELETE FROM test"
const SQL_QUERY_ROW_COUNT = "SELECT count(*) FROM test"

const POSTGRES_CREATE_TEST_TABLE_WITH_SERIAL = "CREATE TABLE IF NOT EXISTS test (id SERIAL, name varchar(10) NOT NULL, PRIMARY KEY (ID))"
const POSTGRES_INSERT_TEST_ROW = "INSERT INTO test(name) VALUES('Grunty') RETURNING id"
const POSTGRES_DROP_TEST_TABLE = "DROP TABLE IF EXISTS test"

func getRandomRegion(t *testing.T, projectID string) string {
	approvedRegions := []string{"europe-north1", "europe-west1", "europe-west2", "europe-west3", "us-central1", "us-east1", "us-west1"}
	//approvedRegions := []string{"europe-north1"}
	return gcp.GetRandomRegion(t, projectID, approvedRegions, []string{})
}

func getTwoDistinctRandomZonesForRegion(t *testing.T, projectID string, region string) (string, string) {
	firstZone := gcp.GetRandomZoneForRegion(t, projectID, region)
	secondZone := gcp.GetRandomZoneForRegion(t, projectID, region)
	for {
		if firstZone != secondZone {
			break
		}
		secondZone = gcp.GetRandomZoneForRegion(t, projectID, region)
	}

	return firstZone, secondZone
}

func createTerratestOptionsForCloudSql(projectId string, region string, exampleDir string, namePrefix string) *terraform.Options {
	terratestOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: exampleDir,
		Vars: map[string]interface{}{
			"region":               region,
			"project":              projectId,
			"name_prefix":          namePrefix,
			"db_name":              DB_NAME,
			"master_user_name":     DB_USER,
			"master_user_password": DB_PASS,
		},
	}

	return terratestOptions
}

func createTerratestOptionsForCloudSqlReplicas(projectId string, region string, exampleDir string, namePrefix string, masterZone string, failoverReplicaZone string, numReadReplicas int, readReplicaZone string) *terraform.Options {
	terratestOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: exampleDir,
		Vars: map[string]interface{}{
			"region":                region,
			"master_zone":           masterZone,
			"num_read_replicas":     numReadReplicas,
			"read_replica_zones":    []string{readReplicaZone},
			"failover_replica_zone": failoverReplicaZone,
			"project":               projectId,
			"name_prefix":           namePrefix,
			"db_name":               DB_NAME,
			"master_user_name":      DB_USER,
			"master_user_password":  DB_PASS,
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

func createTempFile(t *testing.T, content []byte) *os.File {
	tmpFile, err := ioutil.TempFile(os.TempDir(), "temp-")
	require.NoError(t, err, "Failed to create temp file")
	_, err = tmpFile.Write(content)
	require.NoError(t, err, "Failed to write to temp file")
	err = tmpFile.Close()
	require.NoError(t, err, "Failed to close temp file")
	return tmpFile
}
