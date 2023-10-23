package artifact

import (
	"bytes"
	"encoding/json"
	"github.com/pkg/errors"
	"strings"
	"sync/atomic"

	v1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/google/go-containerregistry/pkg/v1/partial"
	"github.com/google/go-containerregistry/pkg/v1/types"
	"github.com/opencontainers/go-digest"
	specv1 "github.com/opencontainers/image-spec/specs-go/v1"
)

type Config interface {
	ArtifactType() (string, error)
	ConfigMediaType() (string, error)
	RawConfigFile() ([]byte, error)
}

func EmptyConfig(artifactType string) Config {
	return &emptyConfigArtifact{
		artifactType: artifactType,
	}
}

type emptyConfigArtifact struct {
	artifactType string
}

func (i *emptyConfigArtifact) ArtifactType() (string, error) {
	return i.artifactType, nil
}

func (i *emptyConfigArtifact) ConfigMediaType() (string, error) {
	return "application/vnd.oci.empty.v1+json", nil
}

func (i *emptyConfigArtifact) RawConfigFile() ([]byte, error) {
	return []byte("{}"), nil
}

func WithTag(tags ...string) BuildOptionFunc {
	return func(o *artifactImage) {
		if len(tags) > 0 {
			if o.annotations == nil {
				o.annotations = map[string]string{}
			}
			o.annotations["org.opencontainers.image.ref.name"] = FixedTag(tags[0])
		}
	}
}

func WithAnnotations(annotations map[string]string) BuildOptionFunc {
	return func(o *artifactImage) {
		if len(annotations) > 0 {
			if o.annotations == nil {
				o.annotations = map[string]string{}
			}
			for key := range annotations {
				o.annotations[key] = annotations[key]
			}
		}
	}
}

func WithPlatform(p specv1.Platform) BuildOptionFunc {
	return func(o *artifactImage) {
		o.platform = &p
	}
}

func FixedTag(tag string) string {
	parts := strings.SplitN(tag, ":", 2)
	if len(parts) == 1 {
		return strings.Join([]string{
			parts[0],
			"latest",
		}, ":")
	}
	return tag
}

type BuildOptionFunc = func(o *artifactImage)

func ToImage(a Config, artifacts []Artifact, optionFuncs ...BuildOptionFunc) (v1.Image, error) {
	img := &artifactImage{
		config: a,
		layers: artifacts,
	}

	for i := range optionFuncs {
		optionFuncs[i](img)
	}

	return img, nil
}

type artifactImage struct {
	config      Config
	layers      []v1.Layer
	platform    *specv1.Platform
	annotations map[string]string
	m           atomic.Pointer[specv1.Manifest]
}

func (i *artifactImage) MediaType() (types.MediaType, error) {
	return types.OCIManifestSchema1, nil
}

func (i *artifactImage) RawConfigFile() ([]byte, error) {
	return i.config.RawConfigFile()
}

func (i *artifactImage) RawManifest() ([]byte, error) {
	m, err := i.OCIManifest()
	if err != nil {
		return nil, err
	}
	return json.Marshal(m)
}

func (i *artifactImage) OCIManifest() (*specv1.Manifest, error) {
	if m := i.m.Load(); m != nil {
		return m, nil
	}

	b, err := i.RawConfigFile()
	if err != nil {
		return nil, err
	}

	cfgHash, cfgSize, err := v1.SHA256(bytes.NewReader(b))
	if err != nil {
		return nil, err
	}

	mediaType, err := i.MediaType()
	if err != nil {
		return nil, err
	}

	artifactType, err := i.config.ArtifactType()
	if err != nil {
		return nil, err
	}

	configMediaType, err := i.config.ConfigMediaType()
	if err != nil {
		return nil, err
	}

	m := &specv1.Manifest{
		MediaType:    string(mediaType),
		ArtifactType: artifactType,
		Config: specv1.Descriptor{
			MediaType: configMediaType,
			Size:      cfgSize,
			Digest:    digest.Digest(cfgHash.String()),
			Platform:  i.platform,
		},
		Annotations: i.annotations,
	}

	m.SchemaVersion = 2

	for _, l := range i.layers {
		mt, err := l.MediaType()
		if err != nil {
			return nil, err
		}
		d, err := l.Digest()
		if err != nil {
			return nil, err
		}
		s, err := l.Size()
		if err != nil {
			return nil, err
		}

		m.Layers = append(m.Layers, specv1.Descriptor{
			MediaType: string(mt),
			Digest:    digest.Digest(d.String()),
			Size:      s,
		})
	}

	i.m.Store(m)
	return m, nil
}

func (i *artifactImage) Manifest() (*v1.Manifest, error) {
	raw, err := i.RawManifest()
	if err != nil {
		return nil, err
	}

	m := &v1.Manifest{}

	if err := json.Unmarshal(raw, m); err != nil {
		return nil, err
	}

	return m, nil
}

func (i *artifactImage) Layers() ([]v1.Layer, error) {
	return i.layers, nil
}

func (i *artifactImage) ConfigFile() (*v1.ConfigFile, error) {
	return nil, errors.New("ConfigFile not supported")
}

func (i *artifactImage) ConfigName() (v1.Hash, error) {
	return partial.ConfigName(i)
}

func (i *artifactImage) Size() (int64, error) {
	return partial.Size(i)
}

func (i *artifactImage) Digest() (v1.Hash, error) {
	return partial.Digest(i)
}

func (i *artifactImage) LayerByDigest(hash v1.Hash) (v1.Layer, error) {
	return nil, nil
}

func (i *artifactImage) LayerByDiffID(hash v1.Hash) (v1.Layer, error) {
	return nil, nil
}
