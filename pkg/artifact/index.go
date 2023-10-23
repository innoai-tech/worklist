package artifact

import (
	"encoding/json"
	"fmt"
	v1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/google/go-containerregistry/pkg/v1/partial"
	"github.com/google/go-containerregistry/pkg/v1/types"
)

func Index(images []v1.Image) (v1.ImageIndex, error) {
	manifest := &v1.IndexManifest{
		SchemaVersion: 2,
		MediaType:     types.OCIImageIndex,
		Manifests:     []v1.Descriptor{},
	}

	idx := &index{
		manifest: manifest,
		images:   map[v1.Hash]v1.Image{},
	}

	for _, img := range images {
		digest, err := img.Digest()
		if err != nil {
			return nil, err
		}
		mediaType, err := img.MediaType()
		if err != nil {
			return nil, err
		}
		size, err := img.Size()
		if err != nil {
			return nil, err
		}
		m, err := img.Manifest()
		if err != nil {
			return nil, err
		}

		manifest.Manifests = append(manifest.Manifests, v1.Descriptor{
			Digest:      digest,
			Size:        size,
			MediaType:   mediaType,
			Annotations: m.Annotations,
			Platform:    m.Config.Platform,
		})

		idx.images[digest] = img

	}

	return idx, nil
}

type index struct {
	manifest *v1.IndexManifest
	images   map[v1.Hash]v1.Image
}

func (i *index) MediaType() (types.MediaType, error) {
	return i.manifest.MediaType, nil
}

func (i *index) Digest() (v1.Hash, error) {
	return partial.Digest(i)
}

func (i *index) Size() (int64, error) {
	return partial.Size(i)
}

func (i *index) IndexManifest() (*v1.IndexManifest, error) {
	return i.manifest, nil
}

func (i *index) RawManifest() ([]byte, error) {
	m, err := i.IndexManifest()
	if err != nil {
		return nil, err
	}
	return json.Marshal(m)
}

func (i *index) Image(h v1.Hash) (v1.Image, error) {
	if img, ok := i.images[h]; ok {
		return img, nil
	}
	return nil, fmt.Errorf("image not found: %v", h)
}

func (i *index) ImageIndex(h v1.Hash) (v1.ImageIndex, error) {
	// This is a single level index (for now?).
	return nil, fmt.Errorf("image not found: %v", h)
}
