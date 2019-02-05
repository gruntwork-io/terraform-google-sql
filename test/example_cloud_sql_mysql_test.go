package test

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"path/filepath"
	"strings"
	"testing"
)

const DB_NAME = "testdb"
const DB_USER = "testuser"
const DB_PASS = "testpassword"
const NAME_PREFIX = "mysql-test"
const MYSQL_VERSION = "MYSQL_5_7"
const EXAMPLE_NAME = "cloud-sql-mysql"

const KEY_REGION = "region"
const KEY_PROJECT = "project"

const OUTPUT_INSTANCE_NAME = "instance_name"
const OUTPUT_PROXY_CONNECTION = "proxy_connection"
const OUTPUT_DB_NAME = "db_name"
const OUTPUT_PUBLIC_IP = "public_ip"

func TestCloudSQLMySql(t *testing.T) {
	t.Parallel()

	//os.Setenv("SKIP_bootstrap", "true")
	//os.Setenv("SKIP_deploy", "true")
	//os.Setenv("SKIP_validate_outputs", "true")
	//os.Setenv("SKIP_sql_tests", "true")
	//os.Setenv("SKIP_teardown", "true")

	_examplesDir := test_structure.CopyTerraformFolderToTemp(t, "../", "examples")
	exampleDir := filepath.Join(_examplesDir, EXAMPLE_NAME)

	test_structure.RunTestStage(t, "bootstrap", func() {
		projectId := gcp.GetGoogleProjectIDFromEnvVar(t)
		region := getRandomRegion(t, projectId)

		test_structure.SaveString(t, exampleDir, KEY_REGION, region)
		test_structure.SaveString(t, exampleDir, KEY_PROJECT, projectId)
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		region := test_structure.LoadString(t, exampleDir, KEY_REGION)
		projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)
		terraformOptions := createTerratestOptionsForMySql(projectId, region, exampleDir)
		test_structure.SaveTerraformOptions(t, exampleDir, terraformOptions)

		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate_outputs", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)

		region := test_structure.LoadString(t, exampleDir, KEY_REGION)
		projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)

		instanceNameFromOutput := terraform.Output(t, terraformOptions, OUTPUT_INSTANCE_NAME)
		dbNameFromOutput := terraform.Output(t, terraformOptions, OUTPUT_DB_NAME)
		proxyConnectionFromOutput := terraform.Output(t, terraformOptions, OUTPUT_PROXY_CONNECTION)

		expectedDBConn := fmt.Sprintf("%s:%s:%s", projectId, region, instanceNameFromOutput)

		assert.True(t, strings.HasPrefix(instanceNameFromOutput, NAME_PREFIX))
		assert.Equal(t, DB_NAME, dbNameFromOutput)
		assert.Equal(t, expectedDBConn, proxyConnectionFromOutput)
	})

	test_structure.RunTestStage(t, "sql_tests", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)

		publicIp := terraform.Output(t, terraformOptions, OUTPUT_PUBLIC_IP)

		connectionString := fmt.Sprintf("%s:%s@tcp(%s:3306)/%s", DB_USER, DB_PASS, publicIp, DB_NAME)

		// Does not actually open up the connection - just returns a DB ref
		logger.Logf(t, "Connecting to: %s", publicIp)
		db, err := sql.Open("mysql",
			connectionString)

		if err != nil {
			t.Fatalf("Failed to open DB connection: %v", err)
		}

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
		logger.Logf(t, "Empty table: %s", MYSQL_EMPTY_TEST_TABLE_STATEMENT)
		if _, err = db.Exec(MYSQL_EMPTY_TEST_TABLE_STATEMENT); err != nil {
			t.Fatalf("Failed to clean up table: %v", err)
		}

		// Insert data to check that our auto-increment flags worked
		logger.Logf(t, "Insert data: %s", MYSQL_INSERT_TEST_ROW)
		stmt, err := db.Prepare(MYSQL_INSERT_TEST_ROW)
		if err != nil {
			t.Fatalf("Failed to prepare statement: %v", err)
		}

		// Execute the statement
		res, err := stmt.Exec("Grunt")
		if err != nil {
			t.Fatalf("Failed to execute statement: %v", err)
		}

		// Get the last insert id
		lastId, err := res.LastInsertId()
		if err != nil {
			t.Fatalf("Failed to get last insert id: %v", err)
		}
		// Since we set the auto increment to 5, modulus should always be 0
		assert.Equal(t, int64(0), int64(lastId%5))
	})
}

func createTerratestOptionsForMySql(projectId string, region string, exampleDir string) *terraform.Options {

	terratestOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: exampleDir,
		Vars: map[string]interface{}{
			"region":               region,
			"project":              projectId,
			"name_prefix":          NAME_PREFIX,
			"mysql_version":        MYSQL_VERSION,
			"db_name":              DB_NAME,
			"master_user_name":     DB_USER,
			"master_user_password": DB_PASS,
		},
	}

	return terratestOptions
}
