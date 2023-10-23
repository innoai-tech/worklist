package distribution

import (
	"encoding/json"
	"os"
	"reflect"
	"testing"

	"github.com/innoai-tech/worklist/pkg/jtd/convert"
)

func TestConfig(t *testing.T) {
	m := convert.ToJSONSchema(convert.Extract(reflect.TypeOf(Config{})))

	file, _ := os.OpenFile("config.schema.json", os.O_RDWR|os.O_CREATE, os.ModePerm)
	defer file.Close()
	_ = file.Truncate(0)
	enc := json.NewEncoder(file)
	enc.SetIndent("", "  ")
	_ = enc.Encode(m)
}
