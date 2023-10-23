package collection

import (
	testingx "github.com/octohelm/x/testing"
	"testing"
)

func TestOrderedMap(t *testing.T) {
	m := &OrderedMap[string, any]{}
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
			m2 := &OrderedMap[string, any]{}
			err := m2.UnmarshalJSON(data)
			testingx.Expect(t, err, testingx.Be[error](nil))
			data2, _ := m2.MarshalJSON()
			testingx.Expect(t, string(data2), testingx.Equal(expectData))
		})
	})
}
