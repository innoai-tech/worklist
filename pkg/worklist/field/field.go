package field

import (
	"context"

	"github.com/innoai-tech/worklist/pkg/md"
)

type Field struct {
	Label       string `json:"label"`
	Description string `json:"description,omitempty"`
}

func (f *Field) PostProcess(ctx context.Context, filename string) error {
	if f.Description != "" {
		node, err := md.TheConverter.From(ctx).ParseMarkdown(ctx, []byte(f.Description), filename)
		if err != nil {
			return err
		}
		f.Description = md.FormatString(node)
	}
	return nil
}
