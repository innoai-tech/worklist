package artifact

import (
	"bytes"
	v1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/google/go-containerregistry/pkg/v1/partial"
	"io"

	"github.com/google/go-containerregistry/pkg/v1/types"
)

type Artifact = v1.Layer

func FromOpener(mediaType string, uncompressed func() (io.ReadCloser, error)) (Artifact, error) {
	return partial.UncompressedToLayer(&artifact{
		mediaType:    mediaType,
		uncompressed: uncompressed,
	})
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
}

func (a *artifact) MediaType() (types.MediaType, error) {
	return types.MediaType(a.mediaType + "+gzip"), nil
}

func (a *artifact) DiffID() (v1.Hash, error) {
	return v1.Hash{}, nil
}

func (a *artifact) Uncompressed() (io.ReadCloser, error) {
	return a.uncompressed()
}
