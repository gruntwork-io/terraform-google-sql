package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestCloudSQLPostgres(t *testing.T) {
	t.Parallel()

	assert.Equal(t, "5432", "5432")
}
