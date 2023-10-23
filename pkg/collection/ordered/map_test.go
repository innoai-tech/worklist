package ordered

import (
	"testing"

	testingx "github.com/octohelm/x/testing"
)

func TestMap(t *testing.T) {
	m := &Map[string, any]{}
	m.Set("int", 1)
	m.Set("bool", true)
	m.Set("sub", map[string]any{
		"a": "a",
	})

	expectData := `{"int":1,"bool":true,"sub":{"a":"a"}}`

	t.Run("MarshalJSON", func(t *testing.T) {
		data, _ := m.MarshalJSON()
		testingx.Expect(t, string(data), testingx.Equal(expectData))

		t.Run("UnmarshalJSON", func(t *testing.T) {
			m2 := &Map[string, any]{}
			err := m2.UnmarshalJSON(data)
			testingx.Expect(t, err, testingx.Be[error](nil))
			data2, _ := m2.MarshalJSON()
			testingx.Expect(t, string(data2), testingx.Equal(expectData))
		})
	})
}
