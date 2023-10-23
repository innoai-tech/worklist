package main

import (
	"context"
	"github.com/google/go-containerregistry/pkg/authn"
	"github.com/google/go-containerregistry/pkg/crane"
	"github.com/innoai-tech/infra/pkg/cli"
	"github.com/innoai-tech/worklist/pkg/artifact"
	"github.com/innoai-tech/worklist/pkg/worklist/loader"
	"log/slog"
	"os"
	"path/filepath"
)

func init() {
	cli.AddTo(App, &Build{})
}

// Build the arg
type Build struct {
	cli.C
	Builder
}

type Builder struct {
	Context           string            `arg:""`
	Push              bool              `flag:"push,omitempty"`
	Tag               []string          `flag:"tag,omitempty"`
	ContainerRegistry ContainerRegistry `flag:",omitempty"`
}

type ContainerRegistry struct {
	Username string `flag:",omitempty"`
	Password string `flag:",omitempty"`
}

func (s *Builder) Run(ctx context.Context) error {
	cwd, err := os.Getwd()
	if err != nil {
		return err
	}

	w, err := loader.Load(ctx, loader.WithWorkingDir(filepath.Join(cwd, s.Context)))
	if err != nil {
		return err
	}

	img, err := w.Build(artifact.WithTag(s.Tag...))
	if err != nil {
		return err
	}

	if s.Push {
		registryAuth := authn.FromConfig(authn.AuthConfig{
			Username: s.ContainerRegistry.Username,
			Password: s.ContainerRegistry.Password,
		})

		for _, tag := range s.Tag {
			tag = artifact.FixedTag(tag)
			err := crane.Push(img, tag, crane.WithAuth(registryAuth))
			if err != nil {
				return err
			}
			slog.Info("pushed.", "tag", tag)
		}

		return nil
	}

	f, err := os.OpenFile(filepath.Join(s.Context, "worklist.tar"), os.O_CREATE|os.O_RDWR, os.ModePerm)
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
