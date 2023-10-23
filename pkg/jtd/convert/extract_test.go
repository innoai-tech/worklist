package convert

import (
	"encoding/json"
	"reflect"
	"testing"
)

type Custom string

type Sub struct {
	ID  int    `json:"a"`
	Str Custom `json:"str,omitempty"`
}

type SomeStruct struct {
	Sub
	Others map[string]string `json:"other,omitempty"`
}

func TestExtract(t *testing.T) {
	s := Extract(reflect.TypeOf(SomeStruct{}))
	data, _ := json.Marshal(ToJSONSchema(s))
	t.Log(string(data))
}
