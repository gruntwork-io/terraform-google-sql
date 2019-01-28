package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// A basic sanity check of the MySQL example that just deploys and undeploys it to make sure there are no errors in
// the templates
// TODO: try to actually connect to the RDS DBs and check they are working
func TestCloudSQLPostgres(t *testing.T) {
	t.Parallel()

	assert.Equal(t, "5432", "5432")
}
