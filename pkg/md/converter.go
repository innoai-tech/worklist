package md

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"github.com/innoai-tech/worklist/pkg/artifact"

	"github.com/gomarkdown/markdown/ast"
	"github.com/gomarkdown/markdown/parser"
	"github.com/innoai-tech/worklist/pkg/fsutil"
	"github.com/octohelm/unifs/pkg/filesystem"
	"github.com/octohelm/unifs/pkg/filesystem/local"
	contextx "github.com/octohelm/x/context"
	"github.com/pkg/errors"
)

var TheConverter = contextx.New[Converter]()

type Converter interface {
	ParseMarkdown(ctx context.Context, src []byte, importFile string) (ast.Node, error)

	Artifacts() []artifact.Artifact
}

func WithFS(fs filesystem.FileSystem) OptionFunc {
	return func(o *converter) {
		o.fs = fs
		o.Loader = artifact.NewLoader(artifact.WithFS(fs))
	}
}

type OptionFunc = func(o *converter)

func NewConverter(optionFns ...OptionFunc) Converter {
	c := &converter{
		fs: local.NewFS(""),
	}
	for i := range optionFns {
		optionFns[i](c)
	}
	return c
}

type converter struct {
	fs filesystem.FileSystem
	artifact.Loader
}

func (c *converter) ParseMarkdown(ctx context.Context, src []byte, importFile string) (n ast.Node, err error) {
	n = parser.NewWithExtensions(parser.CommonExtensions).Parse(src)

	try := func(action func() error) ast.WalkStatus {
		if e := action(); e != nil {
			err = e
			return ast.Terminate
		}
		return ast.SkipChildren
	}

	ast.WalkFunc(n, func(node ast.Node, entering bool) ast.WalkStatus {
		if entering {
			switch x := node.(type) {
			case *ast.Link:
				embedLink := findChild(x, func(c ast.Node) bool {
					if txt, ok := c.(*ast.Text); ok {
						if string(txt.Leaf.Literal) == linkAsEmbed {
							return true
						}
					}
					return false
				})
				if embedLink != nil {
					return try(func() error {
						resolved := c.Resolve(string(x.Destination), importFile)
						node, err := c.LoadMarkdown(ctx, resolved)
						if err != nil {
							return err
						}
						replaceNode(x.Parent, x, node)
						return nil
					})
				}
				return ast.SkipChildren
			case *ast.Image:
				return try(func() error {
					addr := c.Resolve(string(x.Destination), importFile)
					a, err := c.Loader.Load(ctx, addr)
					if err != nil {
						return err
					}
					mediaType, err := a.MediaType()
					if err != nil {
						return err
					}

					d, err := a.Digest()
					if err != nil {
						return err
					}
					// blob:<content_type>;<alg>,<hash>
					x.Destination = []byte(fmt.Sprintf("blob:%s;%s,%s", mediaType, d.Algorithm, d.Hex))
					return nil
				})
			}
		}
		return ast.GoToNext
	})

	return
}

func (c *converter) Resolve(dest string, from string) string {
	return filepath.Join(filepath.Dir(from), dest)
}

func (c *converter) LoadMarkdown(ctx context.Context, filename string) (ast.Node, error) {
	if filepath.Ext(filename) != ".md" {
		return nil, errors.Errorf("invalid markdown file: %s", filename)
	}
	f, err := c.fs.OpenFile(context.Background(), filename, os.O_RDONLY, os.ModePerm)
	if err != nil {
		return nil, err
	}
	data, err := fsutil.ReadAll(f)
	if err != nil {
		return nil, err
	}
	return c.ParseMarkdown(ctx, data, filename)
}

const (
	linkAsEmbed = "@embed"
)

func replaceNode(p ast.Node, old ast.Node, new ast.Node) {
	children := p.GetChildren()
	for i, c := range children {
		if c == old {
			children[i] = new
		}
	}
	p.SetChildren(children)
}

func findChild(node ast.Node, where func(c ast.Node) bool) ast.Node {
	for _, c := range node.GetChildren() {
		if where(c) {
			return c
		}
	}
	return nil
}
