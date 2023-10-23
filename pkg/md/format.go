package md

import (
	"github.com/gomarkdown/markdown"
	"github.com/gomarkdown/markdown/ast"

	"github.com/innoai-tech/worklist/pkg/md/renderer"
)

func Format(node ast.Node) []byte {
	return markdown.Render(node, renderer.NewRenderer())
}

func FormatString(node ast.Node) string {
	return string(Format(node))
}
