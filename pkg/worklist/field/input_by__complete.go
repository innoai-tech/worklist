package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputByComplete{})
}

type InputByComplete struct {
	directive.Name `directive:"input_by_complete" on:"INPUT_FIELD_DEFINITION"`

	SearchURL string `json:"searchURL"`
}
