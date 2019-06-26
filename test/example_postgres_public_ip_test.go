package test

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	_ "github.com/GoogleCloudPlatform/cloudsql-proxy/proxy/dialers/postgres"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	_ "github.com/lib/pq"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const NAME_PREFIX_POSTGRES_PUBLIC = "postgres-public"
const EXAMPLE_NAME_POSTGRES_PUBLIC = "postgres-public-ip"

func TestPostgresPublicIP(t *testing.T) {
	t.Parallel()

	//os.Setenv("SKIP_bootstrap", "true")
	//os.Setenv("SKIP_deploy", "true")
	//os.Setenv("SKIP_validate_outputs", "true")
	//os.Setenv("SKIP_sql_tests", "true")
	//os.Setenv("SKIP_proxy_tests", "true")
	//os.Setenv("SKIP_deploy_cert", "true")
	//os.Setenv("SKIP_redeploy", "true")
	//os.Setenv("SKIP_ssl_sql_tests", "true")
	//os.Setenv("SKIP_teardown_cert", "true")
	//os.Setenv("SKIP_teardown", "true")

	_examplesDir := test_structure.CopyTerraformFolderToTemp(t, "../", "examples")
	exampleDir := filepath.Join(_examplesDir, EXAMPLE_NAME_POSTGRES_PUBLIC)
	certExampleDir := filepath.Join(_examplesDir, EXAMPLE_NAME_CERT)

	// BOOTSTRAP VARIABLES FOR THE TESTS
	test_structure.RunTestStage(t, "bootstrap", func() {
		projectId := gcp.GetGoogleProjectIDFromEnvVar(t)
		region := getRandomRegion(t, projectId)

		test_structure.SaveString(t, exampleDir, KEY_REGION, region)
		test_structure.SaveString(t, exampleDir, KEY_PROJECT, projectId)
	})

	// AT THE END OF THE TESTS, RUN `terraform destroy`
	// TO CLEAN UP ANY RESOURCES THAT WERE CREATED
	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
		terraform.Destroy(t, terraformOptions)
	})

	defer test_structure.RunTestStage(t, "teardown_cert", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, certExampleDir)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		region := test_structure.LoadString(t, exampleDir, KEY_REGION)
		projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)
		terraformOptions := createTerratestOptionsForCloudSql(projectId, region, exampleDir, NAME_PREFIX_POSTGRES_PUBLIC)
		test_structure.SaveTerraformOptions(t, exampleDir, terraformOptions)

		terraform.InitAndApply(t, terraformOptions)
	})

	// VALIDATE MODULE OUTPUTS
	test_structure.RunTestStage(t, "validate_outputs", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)

		region := test_structure.LoadString(t, exampleDir, KEY_REGION)
		projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)

		instanceNameFromOutput := terraform.Output(t, terraformOptions, OUTPUT_MASTER_INSTANCE_NAME)
		dbNameFromOutput := terraform.Output(t, terraformOptions, OUTPUT_DB_NAME)
		proxyConnectionFromOutput := terraform.Output(t, terraformOptions, OUTPUT_MASTER_PROXY_CONNECTION)

		expectedDBConn := fmt.Sprintf("%s:%s:%s", projectId, region, instanceNameFromOutput)

		assert.True(t, strings.HasPrefix(instanceNameFromOutput, NAME_PREFIX_POSTGRES_PUBLIC))
		assert.Equal(t, DB_NAME, dbNameFromOutput)
		assert.Equal(t, expectedDBConn, proxyConnectionFromOutput)
	})

	// TEST REGULAR SQL CLIENT
	test_structure.RunTestStage(t, "sql_tests", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)

		publicIp := terraform.Output(t, terraformOptions, OUTPUT_MASTER_PUBLIC_IP)

		connectionString := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", DB_USER, DB_PASS, publicIp, DB_NAME)

		// Does not actually open up the connection - just returns a DB ref
		logger.Logf(t, "Connecting to: %s", publicIp)
		db, err := sql.Open("postgres", connectionString)
		require.NoError(t, err, "Failed to open DB connection")

		// Make sure we clean up properly
		defer db.Close()

		// Run ping to actually test the connection
		logger.Log(t, "Ping the DB")
		if err = db.Ping(); err != nil {
			t.Fatalf("Failed to ping DB: %v", err)
		}

		// Create table if not exists
		logger.Logf(t, "Create table: %s", POSTGRES_CREATE_TEST_TABLE_WITH_SERIAL)
		if _, err = db.Exec(POSTGRES_CREATE_TEST_TABLE_WITH_SERIAL); err != nil {
			t.Fatalf("Failed to create table: %v", err)
		}

		// Clean up
		logger.Logf(t, "Empty table: %s", SQL_EMPTY_TEST_TABLE_STATEMENT)
		if _, err = db.Exec(SQL_EMPTY_TEST_TABLE_STATEMENT); err != nil {
			t.Fatalf("Failed to clean up table: %v", err)
		}

		logger.Logf(t, "Insert data: %s", POSTGRES_INSERT_TEST_ROW)
		var testid int
		err = db.QueryRow(POSTGRES_INSERT_TEST_ROW).Scan(&testid)
		require.NoError(t, err, "Failed to insert data")

		assert.True(t, testid > 0, "Data was inserted")
	})

	// TEST CLOUD SQL PROXY
	test_structure.RunTestStage(t, "proxy_tests", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)

		proxyConn := terraform.Output(t, terraformOptions, OUTPUT_MASTER_PROXY_CONNECTION)

		logger.Logf(t, "Connecting to: %s via Cloud SQL Proxy", proxyConn)

		// Use the Cloud SQL Proxy for queries
		// See https://cloud.google.com/sql/docs/postgres/sql-proxy

		// Note that sslmode=disable is required it does not mean that the connection
		// is unencrypted. All connections via the proxy are completely encrypted.
		datasourceName := fmt.Sprintf("host=%s user=%s dbname=%s password=%s sslmode=disable", proxyConn, DB_USER, DB_NAME, DB_PASS)
		db, err := sql.Open("cloudsqlpostgres", datasourceName)

		require.NoError(t, err, "Failed to open Proxy DB connection")

		// Make sure we clean up properly
		defer db.Close()

		// Run ping to actually test the connection
		logger.Log(t, "Ping the DB via Proxy")
		if err = db.Ping(); err != nil {
			t.Fatalf("Failed to ping DB via Proxy: %v", err)
		}

		logger.Logf(t, "Insert data via Proxy: %s", POSTGRES_INSERT_TEST_ROW)
		var testid int
		err = db.QueryRow(POSTGRES_INSERT_TEST_ROW).Scan(&testid)
		require.NoError(t, err, "Failed to insert data via Proxy")

		assert.True(t, testid > 0, "Assert data was inserted")
	})

	// CREATE CLIENT CERT
	test_structure.RunTestStage(t, "deploy_cert", func() {
		region := test_structure.LoadString(t, exampleDir, KEY_REGION)
		projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)

		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
		instanceNameFromOutput := terraform.Output(t, terraformOptions, OUTPUT_MASTER_INSTANCE_NAME)
		commonName := fmt.Sprintf("%s-client", instanceNameFromOutput)

		terraformOptionsForCert := createTerratestOptionsForClientCert(projectId, region, certExampleDir, commonName, instanceNameFromOutput)
		test_structure.SaveTerraformOptions(t, certExampleDir, terraformOptionsForCert)

		terraform.InitAndApply(t, terraformOptionsForCert)
	})

	// REDEPLOY WITH FORCED SSL SETTINGS
	test_structure.RunTestStage(t, "redeploy", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)

		// Force secure connections
		terraformOptions.Vars["require_ssl"] = true
		terraform.InitAndApply(t, terraformOptions)
	})

	// RUN TESTS WITH SECURED CONNECTION
	test_structure.RunTestStage(t, "ssl_sql_tests", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
		terraformOptionsForCert := test_structure.LoadTerraformOptions(t, certExampleDir)

		//********************************************************
		// First test that we're not allowed to connect over insecure connection
		//********************************************************

		publicIp := terraform.Output(t, terraformOptions, OUTPUT_MASTER_PUBLIC_IP)

		connectionString := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", DB_USER, DB_PASS, publicIp, DB_NAME)

		// Does not actually open up the connection - just returns a DB ref
		logger.Logf(t, "Connecting to: %s", publicIp)
		db, err := sql.Open("postgres",
			connectionString)
		require.NoError(t, err, "Failed to open DB connection")

		// Make sure we clean up properly
		defer db.Close()

		// Run ping to actually test the connection
		logger.Log(t, "Ping the DB with forced SSL")
		if err = db.Ping(); err != nil {
			logger.Logf(t, "Not allowed to ping %s as expected.", publicIp)
		} else {
			t.Fatalf("Ping %v succeeded against the odds.", publicIp)
		}

		//********************************************************
		// Test connection over secure connection
		//********************************************************

		// Prepare certificates
		serverCertB := []byte(terraform.Output(t, terraformOptions, OUTPUT_MASTER_CA_CERT))
		clientCertB := []byte(terraform.Output(t, terraformOptionsForCert, OUTPUT_CLIENT_CA_CERT))
		clientPKB := []byte(terraform.Output(t, terraformOptionsForCert, OUTPUT_CLIENT_PRIVATE_KEY))

		serverCertFile := createTempFile(t, serverCertB)
		defer os.Remove(serverCertFile.Name())

		clientCertFile := createTempFile(t, clientCertB)
		defer os.Remove(clientCertFile.Name())

		clientPKFile := createTempFile(t, clientPKB)
		defer os.Remove(clientPKFile.Name())

		// Prepare the secure connection string and ping the DB
		sslConnectionString := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=require&sslrootcert=%s&sslcert=%s&sslkey=%s", DB_USER, DB_PASS, publicIp, DB_NAME, serverCertFile.Name(), clientCertFile.Name(), clientPKFile.Name())

		db, err = sql.Open("postgres", sslConnectionString)

		// Run ping to actually test the connection with the SSL config
		logger.Log(t, "Ping the DB with forced SSL")
		if err = db.Ping(); err != nil {
			t.Fatalf("Failed to ping DB with forced SSL: %v", err)
		}

		// Drop the test table if it exists
		logger.Logf(t, "Drop table: %s", POSTGRES_DROP_TEST_TABLE)
		if _, err = db.Exec(POSTGRES_DROP_TEST_TABLE); err != nil {
			t.Fatalf("Failed to drop table: %v", err)
		}
	})
}
