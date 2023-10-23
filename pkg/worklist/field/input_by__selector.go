package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputBySelector{})
}

type InputBySelector struct {
	directive.Name `directive:"input_by_selector" on:"INPUT_FIELD_DEFINITION"`

	Options []Option `json:"options"`
}

type Option struct {
	Value any    `json:"value"`
	Label string `json:"label,omitempty"`
}
