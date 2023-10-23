package distribution

import (
	"context"
	"fmt"
	"github.com/go-courier/logr"
	"github.com/google/go-containerregistry/pkg/authn"
	"github.com/google/go-containerregistry/pkg/crane"
	"github.com/google/go-containerregistry/pkg/name"
	v1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/google/go-containerregistry/pkg/v1/remote"
	"github.com/innoai-tech/worklist/pkg/artifact"
)

type ContainerRegistry struct {
	Endpoint string
	Username string `flag:",omitempty"`
	Password string `flag:",omitempty"`
}

func Push(ctx context.Context, c *Config, cr *ContainerRegistry) error {
	images := make([]v1.Image, len(c.Manifests))

	auth := authn.FromConfig(authn.AuthConfig{
		Username: cr.Username,
		Password: cr.Password,
	})

	for i, manifest := range c.Manifests {
		img, err := manifest.ToImage(c)
		if err != nil {
			return err
		}
		d, err := img.Digest()
		if err != nil {
			return err
		}

		dest := fmt.Sprintf("%s/%s@%s", cr.Endpoint, c.Name, d.String())

		if err := crane.Push(
			img,
			dest,
			crane.WithAuth(auth),
		); err != nil {
			return err
		}

		logr.FromContext(ctx).WithValues("digest", dest).Info("pushed.")

		images[i] = img
	}

	tag, err := name.NewTag(fmt.Sprintf("%s/%s:%s", cr.Endpoint, c.Name, c.Version))
	if err != nil {
		return err
	}

	imageIdx, err := artifact.Index(images)
	if err != nil {
		return err
	}

	defer func() {
		logr.FromContext(ctx).WithValues("tag", tag).Info("pushed.")
	}()

	return remote.WriteIndex(tag, imageIdx, remote.WithAuth(auth))
}
