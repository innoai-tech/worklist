package distribution

import (
	"context"
	"fmt"
	"io"
	"mime"
	"os"
	"path"
	"path/filepath"

	v1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/innoai-tech/worklist/pkg/artifact"
	specv1 "github.com/opencontainers/image-spec/specs-go/v1"
	"github.com/pelletier/go-toml/v2"
)

func Load(ctx context.Context, root string) (*Config, error) {
	data, err := os.ReadFile(path.Join(root, "distribution.toml"))
	if err != nil {
		return nil, err
	}

	c := &Config{
		Context: root,
	}
	if err := toml.Unmarshal(data, c); err != nil {
		return nil, err
	}

	if err := patchConfig(c); err != nil {
		return nil, err
	}

	return c, nil
}

func patchConfig(c *Config) error {
	if c.Version == "" {
		for _, m := range c.Manifests {
			if c.Version == "" && m.Platform.OS == "android" {
				if err := patchConfigByAndroid(c, m); err != nil {
					return err
				}

				c.Version = fmt.Sprintf("v%s-%s", m.Annotation("android.versionName"), m.Annotation("android.versionCode"))
			}
		}
	}

	return nil
}

type Config struct {
	Context string `json:"-"`

	Name      string      `json:"name"`
	Version   string      `json:"version,omitempty"`
	Manifests []*Manifest `json:"manifests"`
}

type Manifest struct {
	Artifact    string            `json:"artifact"`
	Platform    specv1.Platform   `json:"platform"`
	Annotations map[string]string `json:"annotations,omitempty"`
}

func (m *Manifest) Annotate(key string, value string) {
	if m.Annotations == nil {
		m.Annotations = map[string]string{}
	}
	m.Annotations[key] = value
}

func (m *Manifest) Annotation(key string) string {
	if m.Annotations == nil {
		return ""
	}
	return m.Annotations[key]
}

func (m *Manifest) ToImage(c *Config, optionFuncs ...artifact.BuildOptionFunc) (v1.Image, error) {
	artifactType := mime.TypeByExtension(filepath.Ext(m.Artifact))

	artifactLayer, err := artifact.FromOpener(
		artifactType, func() (io.ReadCloser, error) {
			return os.Open(filepath.Join(c.Context, m.Artifact))
		},
	)

	if err != nil {
		return nil, err
	}

	return artifact.ToImage(
		artifact.EmptyConfig(artifactType),
		[]artifact.Artifact{artifactLayer},
		append(
			optionFuncs,
			artifact.WithPlatform(m.Platform),
			artifact.WithAnnotations(m.Annotations),
		)...,
	)
}
