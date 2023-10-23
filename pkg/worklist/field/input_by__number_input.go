package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputByNumberInput{})
}

type InputByNumberInput struct {
	directive.Name `directive:"input_by_number_input" on:"INPUT_FIELD_DEFINITION"`

	Min int `json:"min,omitempty"`
	Max int `json:"max,omitempty"`
}
