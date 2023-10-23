package artifact

import (
	"bytes"
	"io"
	"strings"
	"sync"

	v1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/google/go-containerregistry/pkg/v1/partial"
	"github.com/google/go-containerregistry/pkg/v1/types"
)

type Artifact = v1.Layer

func FromOpener(mediaType string, uncompressed func() (io.ReadCloser, error)) (Artifact, error) {
	return &artifact{
		mediaType:    mediaType,
		gzipEnabled:  strings.HasSuffix(mediaType, "+gzip"),
		uncompressed: uncompressed,
	}, nil
}

func FromReader(mediaType string, r io.Reader) (Artifact, error) {
	return partial.UncompressedToLayer(&artifact{
		mediaType: mediaType,
		uncompressed: func() (io.ReadCloser, error) {
			if rc, ok := r.(io.ReadCloser); ok {
				return rc, nil
			}
			return io.NopCloser(r), nil
		},
	})
}

func FromBytes(mediaType string, data []byte) (Artifact, error) {
	return FromReader(mediaType, bytes.NewReader(data))
}

type artifact struct {
	mediaType    string
	uncompressed func() (io.ReadCloser, error)

	gzipEnabled   bool
	hashSizeError error
	hash          v1.Hash
	size          int64
	once          sync.Once
}

func (a *artifact) DiffID() (v1.Hash, error) {
	return v1.Hash{}, nil
}

func (a *artifact) Uncompressed() (io.ReadCloser, error) {
	return a.uncompressed()
}

func (a *artifact) MediaType() (types.MediaType, error) {
	return types.MediaType(a.mediaType), nil
}

func (a *artifact) Compressed() (io.ReadCloser, error) {
	if a.gzipEnabled {
		u, err := partial.UncompressedToLayer(a)
		if err != nil {
			return nil, err
		}
		return u.Compressed()
	}
	return a.Uncompressed()
}

func (a *artifact) Digest() (v1.Hash, error) {
	a.calcSizeHash()
	return a.hash, a.hashSizeError
}

func (a *artifact) Size() (int64, error) {
	a.calcSizeHash()
	return a.size, a.hashSizeError
}

func (a *artifact) calcSizeHash() {
	a.once.Do(func() {
		r, err := a.Compressed()
		if err != nil {
			a.hashSizeError = err
			return
		}
		defer r.Close()
		a.hash, a.size, a.hashSizeError = v1.SHA256(r)
	})
}
