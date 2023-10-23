package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputByTextInput{})
}

// 输入类型：文本
type InputByTextInput struct {
	directive.Name `directive:"input_by_text_input" on:"FIELD_DEFINITION"`

	// 文本预设格式
	Format string `json:"format,omitempty"`
	// 文本限制
	Mask string `json:"mask,omitempty"`
	// 格式正则约束
	Pattern string `json:"pattern,omitempty"`
	// 最小字符数
	MinChars int `json:"minChars,omitempty"`
	// 最大字符数
	MaxChars int `json:"maxChars,omitempty"`
}
