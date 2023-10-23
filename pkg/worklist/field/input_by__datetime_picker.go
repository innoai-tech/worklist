package field

import (
	"time"

	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputByDatetimePicker{})
}

// 输入类型: 日期时间选择
type InputByDatetimePicker struct {
	directive.Name `directive:"input_by_datetime_picker" on:"FIELD_DEFINITION"`

	// 显示格式
	//
	// 默认值 yyyy-MM-dd HH:mm
	// 当只有日期相关格式时，时间选择器省略
	Format string `json:"format,omitempty"`

	// 最小时间
	Min *time.Time `json:"min,omitempty"`
	// 最大时间
	Max *time.Time `json:"max,omitempty"`
}
