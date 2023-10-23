package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputByFileSelector{})
}

type InputByFileSelector struct {
	directive.Name `directive:"input_by_file_selector" on:"INPUT_FIELD_DEFINITION"`

	Accept string `json:"accept,omitempty"`
}
