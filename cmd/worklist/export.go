package main

import (
	"context"
	"github.com/innoai-tech/infra/pkg/cli"
	"github.com/innoai-tech/worklist/pkg/artifact"
	"github.com/innoai-tech/worklist/pkg/fsutil"
	"github.com/octohelm/unifs/pkg/filesystem/local"
	"log/slog"
	"os"
	"path/filepath"
)

func init() {
	cli.AddTo(App, &Export{})
}

// Export the worklist as tar
type Export struct {
	cli.C
	Exporter
}

type Exporter struct {
	Image

	Output string `flag:"output"`
}

func (s *Exporter) Run(ctx context.Context) error {
	img, err := s.Load(ctx)
	if err != nil {
		return err
	}

	cwd, err := os.Getwd()
	if err != nil {
		return err
	}

	fs := local.NewLocalFS(cwd)

	if err := fsutil.MkdirAll(ctx, fs, filepath.Dir(s.Output), os.ModePerm); err != nil {
		return err
	}
	f, err := fs.OpenFile(ctx, s.Output, os.O_CREATE|os.O_RDWR, os.ModePerm)
	if err != nil {
		return err
	}
	defer f.Close()

	if err := artifact.Export(img, f); err != nil {
		return err
	}
	slog.Info("exported.")
	return nil
}
