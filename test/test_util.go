package test

import (
	"github.com/gruntwork-io/terratest/modules/gcp"
	"testing"
)

const MYSQL_CREATE_TEST_TABLE_WITH_AUTO_INCREMENT_STATEMENT = "CREATE TABLE IF NOT EXISTS test (id int NOT NULL AUTO_INCREMENT, name varchar(10) NOT NULL, PRIMARY KEY (ID))"
const MYSQL_EMPTY_TEST_TABLE_STATEMENT = "DELETE FROM test"
const MYSQL_INSERT_TEST_ROW = "INSERT INTO test(name) VALUES(?)"

func getRandomRegion(t *testing.T, projectID string) string {
	//approvedRegions := []string{"europe-north1", "europe-west1", "europe-west2", "europe-west3", "us-central1", "us-east1", "us-west1"}
	approvedRegions := []string{"europe-north1"}
	return gcp.GetRandomRegion(t, projectID, approvedRegions, []string{})
}
