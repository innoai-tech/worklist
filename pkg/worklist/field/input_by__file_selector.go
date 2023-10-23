package field

import (
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func init() {
	gql.RegisterDirective(&InputByFileSelector{})
}

// 输入类型：文件选择器
type InputByFileSelector struct {
	directive.Name `directive:"input_by_file_selector" on:"FIELD_DEFINITION"`

	// 支持的文件类型
	//
	// 不支持 文件扩展名，只认 MIME type 全称
	// 可用 image/*
	//
	// 当为 image/* 时，为图片选择
	Accept string `json:"accept,omitempty"`
}
