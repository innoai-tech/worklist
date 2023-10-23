package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputBySelector{})
}

// 输入类型： 选项
type InputBySelector struct {
	directive.Name `directive:"input_by_selector" on:"FIELD_DEFINITION"`

	// 可用选项
	Options []Option `json:"options"`
}

type Option struct {
	// 选项值
	Value any `json:"value"`
	// 选项描述
	Label string `json:"label,omitempty"`
}
