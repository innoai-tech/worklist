package main

import (
	"context"
	"github.com/google/go-containerregistry/pkg/authn"
	"github.com/google/go-containerregistry/pkg/crane"
	v1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/innoai-tech/infra/pkg/cli"
	"github.com/innoai-tech/worklist/pkg/artifact"
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
	"github.com/innoai-tech/worklist/pkg/worklist/loader"
	"log/slog"
	"os"
	"path/filepath"
)

func init() {
	cli.AddTo(App, &Build{})
}

// Load the arg
type Build struct {
	cli.C
	Builder
}

type Builder struct {
	Image

	Push              bool              `flag:"push,omitempty"`
	ContainerRegistry ContainerRegistry `flag:",omitempty"`
}

type ContainerRegistry struct {
	Username string `flag:",omitempty"`
	Password string `flag:",omitempty"`
}

func (s *Builder) Run(ctx context.Context) error {
	img, err := s.Image.Load(ctx)
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

	return nil
}

type Image struct {
	Context string   `arg:""`
	Tag     []string `flag:"tag,omitempty"`
}

func (i *Image) Load(ctx context.Context) (v1.Image, error) {
	cwd, err := os.Getwd()
	if err != nil {
		return nil, err
	}

	workingDir := filepath.Join(cwd, i.Context)

	data, err := gql.Format(gql.NewSchemaConfig())
	if err != nil {
		return nil, err
	}
	if err := os.WriteFile(filepath.Join(workingDir, "worklist.d.gql"), data, os.ModePerm); err != nil {
		return nil, err
	}

	w, err := loader.Load(
		ctx,
		loader.WithWorkingDir(workingDir),
	)
	if err != nil {
		return nil, err
	}

	return w.Build(artifact.WithTag(i.Tag...))
}
