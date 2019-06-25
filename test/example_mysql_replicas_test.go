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
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const NAME_PREFIX_REPLICAS = "mysql-replicas"
const EXAMPLE_NAME_REPLICAS = "mysql-replicas"

func TestMySqlReplicas(t *testing.T) {
	t.Parallel()

	//os.Setenv("SKIP_bootstrap", "true")
	//os.Setenv("SKIP_deploy", "true")
	//os.Setenv("SKIP_validate_outputs", "true")
	//os.Setenv("SKIP_sql_tests", "true")
	//os.Setenv("SKIP_read_replica_tests", "true")
	//os.Setenv("SKIP_teardown", "true")

	_examplesDir := test_structure.CopyTerraformFolderToTemp(t, "../", "examples")
	exampleDir := filepath.Join(_examplesDir, EXAMPLE_NAME_REPLICAS)

	// BOOTSTRAP VARIABLES FOR THE TESTS
	test_structure.RunTestStage(t, "bootstrap", func() {
		projectId := gcp.GetGoogleProjectIDFromEnvVar(t)
		region := getRandomRegion(t, projectId)

		masterZone, failoverReplicaZone := getTwoDistinctRandomZonesForRegion(t, projectId, region)
		readReplicaZone := gcp.GetRandomZoneForRegion(t, projectId, region)

		test_structure.SaveString(t, exampleDir, KEY_REGION, region)
		test_structure.SaveString(t, exampleDir, KEY_MASTER_ZONE, masterZone)
		test_structure.SaveString(t, exampleDir, KEY_FAILOVER_REPLICA_ZONE, failoverReplicaZone)
		test_structure.SaveString(t, exampleDir, KEY_READ_REPLICA_ZONE, readReplicaZone)
		test_structure.SaveString(t, exampleDir, KEY_PROJECT, projectId)
	})

	// AT THE END OF THE TESTS, RUN `terraform destroy`
	// TO CLEAN UP ANY RESOURCES THAT WERE CREATED
	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		region := test_structure.LoadString(t, exampleDir, KEY_REGION)
		projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)
		masterZone := test_structure.LoadString(t, exampleDir, KEY_MASTER_ZONE)
		failoverReplicaZone := test_structure.LoadString(t, exampleDir, KEY_FAILOVER_REPLICA_ZONE)
		readReplicaZone := test_structure.LoadString(t, exampleDir, KEY_READ_REPLICA_ZONE)
		terraformOptions := createTerratestOptionsForCloudSqlReplicas(projectId, region, exampleDir, NAME_PREFIX_REPLICAS, masterZone, failoverReplicaZone, 1, readReplicaZone)
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

		assert.True(t, strings.HasPrefix(instanceNameFromOutput, NAME_PREFIX_REPLICAS))
		assert.Equal(t, DB_NAME, dbNameFromOutput)
		assert.Equal(t, expectedDBConn, proxyConnectionFromOutput)

		// Failover replica outputs
		failoverInstanceNameFromOutput := terraform.Output(t, terraformOptions, OUTPUT_FAILOVER_INSTANCE_NAME)
		failoverProxyConnectionFromOutput := terraform.Output(t, terraformOptions, OUTPUT_FAILOVER_PROXY_CONNECTION)

		expectedFailoverDBConn := fmt.Sprintf("%s:%s:%s", projectId, region, failoverInstanceNameFromOutput)

		assert.True(t, strings.HasPrefix(failoverInstanceNameFromOutput, NAME_PREFIX_REPLICAS))
		assert.Equal(t, expectedFailoverDBConn, failoverProxyConnectionFromOutput)

		// Read replica outputs
		readReplicaInstanceNameFromOutputList := terraform.OutputList(t, terraformOptions, OUTPUT_READ_REPLICA_INSTANCE_NAMES)
		readReplicaProxyConnectionFromOutputList := terraform.OutputList(t, terraformOptions, OUTPUT_READ_REPLICA_PROXY_CONNECTIONS)

		readReplicaInstanceNameFromOutput := readReplicaInstanceNameFromOutputList[0]
		readReplicaProxyConnectionFromOutput := readReplicaProxyConnectionFromOutputList[0]

		expectedReadReplicaDBConn := fmt.Sprintf("%s:%s:%s", projectId, region, readReplicaInstanceNameFromOutput)

		assert.True(t, strings.HasPrefix(readReplicaInstanceNameFromOutput, NAME_PREFIX_REPLICAS))
		assert.Equal(t, expectedReadReplicaDBConn, readReplicaProxyConnectionFromOutput)
	})

	// TEST REGULAR SQL CLIENT
	test_structure.RunTestStage(t, "sql_tests", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)

		publicIp := terraform.Output(t, terraformOptions, OUTPUT_MASTER_PUBLIC_IP)

		connectionString := fmt.Sprintf("%s:%s@tcp(%s:3306)/%s", DB_USER, DB_PASS, publicIp, DB_NAME)

		// Does not actually open up the connection - just returns a DB ref
		logger.Logf(t, "Connecting to: %s", publicIp)
		db, err := sql.Open("mysql", connectionString)
		require.NoError(t, err, "Failed to open DB connection")

		// Make sure we clean up properly
		defer db.Close()

		// Run ping to actually test the connection
		logger.Log(t, "Ping the DB")
		if err = db.Ping(); err != nil {
			t.Fatalf("Failed to ping DB: %v", err)
		}

		// Create table if not exists
		logger.Logf(t, "Create table: %s", MYSQL_CREATE_TEST_TABLE_WITH_AUTO_INCREMENT_STATEMENT)
		if _, err = db.Exec(MYSQL_CREATE_TEST_TABLE_WITH_AUTO_INCREMENT_STATEMENT); err != nil {
			t.Fatalf("Failed to create table: %v", err)
		}

		// Clean up
		logger.Logf(t, "Empty table: %s", SQL_EMPTY_TEST_TABLE_STATEMENT)
		if _, err = db.Exec(SQL_EMPTY_TEST_TABLE_STATEMENT); err != nil {
			t.Fatalf("Failed to clean up table: %v", err)
		}

		// Insert data to check that our auto-increment flags worked
		logger.Logf(t, "Insert data: %s", MYSQL_INSERT_TEST_ROW)
		stmt, err := db.Prepare(MYSQL_INSERT_TEST_ROW)
		require.NoError(t, err, "Failed to prepare statement")

		// Execute the statement
		res, err := stmt.Exec("Grunt")
		require.NoError(t, err, "Failed to execute statement")

		// Get the last insert id
		lastId, err := res.LastInsertId()
		require.NoError(t, err, "Failed to get last insert id")

		// Since we set the auto increment to 7, modulus should always be 0
		assert.Equal(t, int64(0), int64(lastId%7))
	})

	// TEST READ REPLICA WITH REGULAR SQL CLIENT
	test_structure.RunTestStage(t, "read_replica_tests", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)

		readReplicaPublicIpList := terraform.OutputList(t, terraformOptions, OUTPUT_READ_REPLICA_PUBLIC_IPS)
		readReplicaPublicIp := readReplicaPublicIpList[0]

		connectionString := fmt.Sprintf("%s:%s@tcp(%s:3306)/%s", DB_USER, DB_PASS, readReplicaPublicIp, DB_NAME)

		// Does not actually open up the connection - just returns a DB ref
		logger.Logf(t, "Connecting to read replica: %s", readReplicaPublicIp)
		db, err := sql.Open("mysql", connectionString)
		require.NoError(t, err, "Failed to open DB connection to read replica")

		// Make sure we clean up properly
		defer db.Close()

		// Run ping to actually test the connection
		logger.Log(t, "Ping the read replica DB")
		if err = db.Ping(); err != nil {
			t.Fatalf("Failed to ping read replica DB: %v", err)
		}

		// Try to insert data to verify we cannot write
		logger.Logf(t, "Insert data: %s", MYSQL_INSERT_TEST_ROW)
		stmt, err := db.Prepare(MYSQL_INSERT_TEST_ROW)
		require.NoError(t, err, "Failed to prepare insert readonly statement")

		// Execute the statement
		_, err = stmt.Exec("ReadOnlyGrunt")
		// This time we actually expect an error:
		// 'The MySQL server is running with the --read-only option so it cannot execute this statement'
		require.Error(t, err, "Should not be able to write to read replica")
		logger.Logf(t, "Failed to insert data to read replica as expected: %v", err)

		// Prepare statement for reading data
		stmtOut, err := db.Prepare(SQL_QUERY_ROW_COUNT)
		require.NoError(t, err, "Failed to prepare readonly count statement")

		// Query data, results don't matter...
		logger.Logf(t, "Query r/o data: %s", SQL_QUERY_ROW_COUNT)

		var numResults int

		err = stmtOut.QueryRow().Scan(&numResults)
		require.NoError(t, err, "Failed to execute query statement on read replica")

		logger.Logf(t, "Number of rows... just for fun: %v", numResults)

	})
}
