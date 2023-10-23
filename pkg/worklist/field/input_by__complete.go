package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputByComplete{})
}

// 输入类型：输入补全选项
type InputByComplete struct {
	directive.Name `directive:"input_by_complete" on:"FIELD_DEFINITION"`

	// 查询地址
	// 支持格式 <http_endpoint>?q=<query_string>
	// 并且返回格式为 List<{ label: string, value: any }>
	SearchURL string `json:"searchURL"`
}
