package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputByOperationTime{})
}

// 输入类型：操作时间
type InputByOperationTime struct {
	directive.Name `directive:"input_by_operation_time" on:"FIELD_DEFINITION"`
	// 操作时间类型
	Type OperationTimeType `json:"type"`
}

// 操作时间类型
// +gengo:enum
type OperationTimeType string

const (
	OPERATION_TIME_TYPE__ON_CREATED   OperationTimeType = "ON_CREATED"   // 创建时间
	OPERATION_TIME_TYPE__ON_COMMITTED OperationTimeType = "ON_COMMITTED" // 提交时间
)
