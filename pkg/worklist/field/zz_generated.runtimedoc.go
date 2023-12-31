/*
Package field GENERATED BY gengo:runtimedoc 
DON'T EDIT THIS FILE
*/
package field

// nolint:deadcode,unused
func runtimeDoc(v any, names ...string) ([]string, bool) {
	if c, ok := v.(interface {
		RuntimeDoc(names ...string) ([]string, bool)
	}); ok {
		return c.RuntimeDoc(names...)
	}
	return nil, false
}

func (v Field) RuntimeDoc(names ...string) ([]string, bool) {
	if len(names) > 0 {
		switch names[0] {
		case "Label":
			return []string{}, true
		case "Description":
			return []string{}, true

		}

		return nil, false
	}
	return []string{}, true
}

func (v InputByComplete) RuntimeDoc(names ...string) ([]string, bool) {
	if len(names) > 0 {
		switch names[0] {
		case "SearchURL":
			return []string{
				"查询地址",
				"支持格式 <http_endpoint>?q=<query_string>",
				"并且返回格式为 List<{ label: string, value: any }>",
			}, true

		}

		return nil, false
	}
	return []string{
		"输入类型：输入补全选项",
	}, true
}

func (v InputByDatetimePicker) RuntimeDoc(names ...string) ([]string, bool) {
	if len(names) > 0 {
		switch names[0] {
		case "Format":
			return []string{
				"显示格式",
				"",
				"默认值 yyyy-MM-dd HH:mm",
				"当只有日期相关格式时，时间选择器省略",
			}, true
		case "Min":
			return []string{
				"最小时间",
			}, true
		case "Max":
			return []string{
				"最大时间",
			}, true

		}

		return nil, false
	}
	return []string{
		"输入类型: 日期时间选择",
	}, true
}

func (v InputByFileSelector) RuntimeDoc(names ...string) ([]string, bool) {
	if len(names) > 0 {
		switch names[0] {
		case "Accept":
			return []string{
				"支持的文件类型",
				"",
				"不支持 文件扩展名，只认 MIME type 全称",
				"可用 image/*",
				"",
				"当为 image/* 时，为图片选择",
			}, true

		}

		return nil, false
	}
	return []string{
		"输入类型：文件选择器",
	}, true
}

func (v InputByNumberInput) RuntimeDoc(names ...string) ([]string, bool) {
	if len(names) > 0 {
		switch names[0] {
		case "Min":
			return []string{
				"最小值",
			}, true
		case "Max":
			return []string{
				"最大值",
			}, true

		}

		return nil, false
	}
	return []string{
		"输入类型： 数字",
	}, true
}

func (v InputByOperationTime) RuntimeDoc(names ...string) ([]string, bool) {
	if len(names) > 0 {
		switch names[0] {
		case "Type":
			return []string{
				"操作时间类型",
			}, true

		}

		return nil, false
	}
	return []string{
		"输入类型：操作时间",
	}, true
}

func (v InputBySelector) RuntimeDoc(names ...string) ([]string, bool) {
	if len(names) > 0 {
		switch names[0] {
		case "Options":
			return []string{
				"可用选项",
			}, true

		}

		return nil, false
	}
	return []string{
		"输入类型： 选项",
	}, true
}

func (v InputByTextInput) RuntimeDoc(names ...string) ([]string, bool) {
	if len(names) > 0 {
		switch names[0] {
		case "Format":
			return []string{
				"文本预设格式",
			}, true
		case "Mask":
			return []string{
				"文本限制",
			}, true
		case "Pattern":
			return []string{
				"格式正则约束",
			}, true
		case "MinChars":
			return []string{
				"最小字符数",
			}, true
		case "MaxChars":
			return []string{
				"最大字符数",
			}, true

		}

		return nil, false
	}
	return []string{
		"输入类型：文本",
	}, true
}

func (OperationTimeType) RuntimeDoc(names ...string) ([]string, bool) {
	return []string{
		"操作时间类型",
	}, true
}
func (v Option) RuntimeDoc(names ...string) ([]string, bool) {
	if len(names) > 0 {
		switch names[0] {
		case "Value":
			return []string{
				"选项值",
			}, true
		case "Label":
			return []string{
				"选项描述",
			}, true

		}

		return nil, false
	}
	return []string{}, true
}
