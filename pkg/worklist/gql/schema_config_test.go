package gql_test

import (
	"fmt"
	"testing"

	"github.com/innoai-tech/worklist/pkg/worklist/gql"

	_ "github.com/innoai-tech/worklist/pkg/worklist/field"
)

func TestNewSchemaConfig(t *testing.T) {
	sc := gql.NewSchemaConfig()
	data, _ := gql.Format(sc)
	fmt.Println(string(data))
}
