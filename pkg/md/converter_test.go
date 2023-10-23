package md

import (
	"bytes"
	"context"
	"fmt"
	"testing"

	"github.com/innoai-tech/worklist/pkg/fsutil"
	"github.com/octohelm/unifs/pkg/filesystem"
	testingx "github.com/octohelm/x/testing"
)

func TestConverter(t *testing.T) {
	ctx := context.Background()

	fs := filesystem.NewMemFS()

	err := fsutil.WriteFile(ctx, fs, "docs/assets/logo.png", bytes.NewBufferString(`xxx`))
	testingx.Expect(t, err, testingx.Be[error](nil))

	err = fsutil.WriteFile(ctx, fs, "docs/test.md", bytes.NewBufferString(`
# This project is about x.

![](./assets/logo.png)
`))
	testingx.Expect(t, err, testingx.Be[error](nil))

	c := NewConverter(WithFS(fs))

	node, err := c.ParseMarkdown(ctx, []byte(`
[@embed](./docs/test.md)

	test
	test
`), "./schema.gql")

	testingx.Expect(t, err, testingx.Be[error](nil))

	fmt.Println(FormatString(node))
}
