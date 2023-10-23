package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputByTextInput{})
}

type InputByTextInput struct {
	directive.Name `directive:"input_by_text_input" on:"INPUT_FIELD_DEFINITION"`

	Format    string `json:"format,omitempty"`
	Mask      string `json:"mask,omitempty"`
	MinLength int    `json:"minLength,omitempty"`
	MaxLength int    `json:"maxLength,omitempty"`
	Pattern   string `json:"pattern,omitempty"`
}
