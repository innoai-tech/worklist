package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
	"time"
)

func init() {
	gql.RegisterDirective(&InputByDatetimePicker{})
}

type InputByDatetimePicker struct {
	directive.Name `directive:"input_by_datetime_picker" on:"INPUT_FIELD_DEFINITION"`

	Format string `json:"format,omitempty"`

	Min *time.Time `json:"min,omitempty"`
	Max *time.Time `json:"max,omitempty"`
}
