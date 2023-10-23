package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputByNumberInput{})
}

// 输入类型： 数字
type InputByNumberInput struct {
	directive.Name `directive:"input_by_number_input" on:"FIELD_DEFINITION"`

	// 最小值
	Min int `json:"min,omitempty"`
	// 最大值
	Max int `json:"max,omitempty"`
}
