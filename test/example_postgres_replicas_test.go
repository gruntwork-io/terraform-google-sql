package test

import (
	"database/sql"
	"fmt"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	_ "github.com/lib/pq"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const NAME_PREFIX_POSTGRES_REPLICAS = "postgres-replicas"
const EXAMPLE_NAME_POSTGRES_REPLICAS = "postgres-replicas"

func TestPostgresReplicas(t *testing.T) {
	t.Parallel()

	//os.Setenv("SKIP_bootstrap", "true")
	//os.Setenv("SKIP_deploy", "true")
	//os.Setenv("SKIP_validate_outputs", "true")
	//os.Setenv("SKIP_sql_tests", "true")
	//os.Setenv("SKIP_read_replica_tests", "true")
	//os.Setenv("SKIP_teardown", "true")

	_examplesDir := test_structure.CopyTerraformFolderToTemp(t, "../", "examples")
	exampleDir := filepath.Join(_examplesDir, EXAMPLE_NAME_POSTGRES_REPLICAS)

	// BOOTSTRAP VARIABLES FOR THE TESTS
	test_structure.RunTestStage(t, "bootstrap", func() {
		projectId := gcp.GetGoogleProjectIDFromEnvVar(t)
		region := getRandomRegion(t, projectId)

		masterZone, readReplicaZone := getTwoDistinctRandomZonesForRegion(t, projectId, region)

		test_structure.SaveString(t, exampleDir, KEY_REGION, region)
		test_structure.SaveString(t, exampleDir, KEY_MASTER_ZONE, masterZone)
		test_structure.SaveString(t, exampleDir, KEY_READ_REPLICA_ZONE, readReplicaZone)
		test_structure.SaveString(t, exampleDir, KEY_PROJECT, projectId)
	})

	// AT THE END OF THE TESTS, RUN `terraform destroy`
	// TO CLEAN UP ANY RESOURCES THAT WERE CREATED
	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
		terraform.Destroy(t, terraformOptions)
	})

	// AT THE END OF THE TESTS, CLEAN UP ANY POSTGRES OBJECTS THAT WERE CREATED
	defer test_structure.RunTestStage(t, "cleanup_postgres_objects", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)

		publicIp := terraform.Output(t, terraformOptions, OUTPUT_MASTER_PUBLIC_IP)

		connectionString := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", DB_USER, DB_PASS, publicIp, DB_NAME)

		// Does not actually open up the connection - just returns a DB ref
		logger.Logf(t, "Connecting to: %s", publicIp)
		db, err := sql.Open("postgres", connectionString)
		require.NoError(t, err, "Failed to open DB connection")

		// Make sure we clean up properly
		defer db.Close()

		// Drop table if it exists
		logger.Logf(t, "Drop table: %s", POSTGRES_DROP_TEST_TABLE)
		if _, err = db.Exec(POSTGRES_DROP_TEST_TABLE); err != nil {
			t.Fatalf("Failed to drop table: %v", err)
		}
	})

	test_structure.RunTestStage(t, "deploy", func() {
		region := test_structure.LoadString(t, exampleDir, KEY_REGION)
		projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)
		masterZone := test_structure.LoadString(t, exampleDir, KEY_MASTER_ZONE)
		readReplicaZone := test_structure.LoadString(t, exampleDir, KEY_READ_REPLICA_ZONE)
		terraformOptions := createTerratestOptionsForCloudSqlReplicas(projectId, region, exampleDir, NAME_PREFIX_POSTGRES_REPLICAS, masterZone, "", 1, readReplicaZone)
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

		assert.True(t, strings.HasPrefix(instanceNameFromOutput, NAME_PREFIX_POSTGRES_REPLICAS))
		assert.Equal(t, DB_NAME, dbNameFromOutput)
		assert.Equal(t, expectedDBConn, proxyConnectionFromOutput)

		// Read replica outputs
		readReplicaInstanceNameFromOutputList := terraform.OutputList(t, terraformOptions, OUTPUT_READ_REPLICA_INSTANCE_NAMES)
		readReplicaProxyConnectionFromOutputList := terraform.OutputList(t, terraformOptions, OUTPUT_READ_REPLICA_PROXY_CONNECTIONS)

		readReplicaInstanceNameFromOutput := readReplicaInstanceNameFromOutputList[0]
		readReplicaProxyConnectionFromOutput := readReplicaProxyConnectionFromOutputList[0]

		expectedReadReplicaDBConn := fmt.Sprintf("%s:%s:%s", projectId, region, readReplicaInstanceNameFromOutput)

		assert.True(t, strings.HasPrefix(readReplicaInstanceNameFromOutput, NAME_PREFIX_POSTGRES_REPLICAS))
		assert.Equal(t, expectedReadReplicaDBConn, readReplicaProxyConnectionFromOutput)
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

	// TEST READ REPLICA WITH REGULAR SQL CLIENT
	test_structure.RunTestStage(t, "read_replica_tests", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)

		readReplicaPublicIpList := terraform.OutputList(t, terraformOptions, OUTPUT_READ_REPLICA_PUBLIC_IPS)
		readReplicaPublicIp := readReplicaPublicIpList[0]

		connectionString := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", DB_USER, DB_PASS, readReplicaPublicIp, DB_NAME)

		// Does not actually open up the connection - just returns a DB ref
		logger.Logf(t, "Connecting to: %s", readReplicaPublicIp)
		db, err := sql.Open("postgres", connectionString)
		require.NoError(t, err, "Failed to open DB connection")

		// Make sure we clean up properly
		defer db.Close()

		// Run ping to actually test the connection
		logger.Log(t, "Ping the DB")
		if err = db.Ping(); err != nil {
			t.Fatalf("Failed to ping DB: %v", err)
		}

		// Try to insert data to verify we cannot write
		logger.Logf(t, "Insert data: %s", POSTGRES_INSERT_TEST_ROW)
		var testid int
		err = db.QueryRow(POSTGRES_INSERT_TEST_ROW).Scan(&testid)

		// This time we actually expect an error:
		// 'cannot execute INSERT in a read-only transaction'
		require.Error(t, err, "Should not be able to write to read replica")
		logger.Logf(t, "Failed to insert data to read replica as expected: %v", err)

		// Query data, results don't matter...
		logger.Logf(t, "Query r/o data: %s", SQL_QUERY_ROW_COUNT)
		rows, err := db.Query(SQL_QUERY_ROW_COUNT)
		require.NoError(t, err, "Failed to execute query statement on read replica")

		assert.True(t, rows.Next(), "We have a result")
	})
}
