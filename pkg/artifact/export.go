package artifact

import (
	"archive/tar"
	"bytes"
	"encoding/json"
	"io"
	"path/filepath"

	v1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/google/go-containerregistry/pkg/v1/static"
	"github.com/pkg/errors"
)

func Export(img v1.Image, w io.Writer) error {
	tw := tar.NewWriter(w)
	defer func() {
		_ = tw.Close()
	}()

	manifestRaw, err := img.RawManifest()
	if err != nil {
		return errors.Wrap(err, "retrieving manifest")
	}

	if err := copyToTar(tw, bytes.NewBuffer(manifestRaw), tar.Header{
		Name: "index.json",
		Size: int64(len(manifestRaw)),
	}); err != nil {
		return nil
	}

	ociLayoutRaw, _ := json.Marshal(map[string]string{"imageLayoutVersion": "1.0.0"})

	if err := copyToTar(tw, bytes.NewBuffer(ociLayoutRaw), tar.Header{
		Name: "oci-layout",
		Size: int64(len(ociLayoutRaw)),
	}); err != nil {
		return nil
	}

	mediaType, err := img.MediaType()
	if err != nil {
		return errors.Wrap(err, "retrieving media type")
	}

	configRaw, err := img.RawConfigFile()
	if err != nil {
		return errors.Wrap(err, "retrieving image config")
	}

	layers, err := img.Layers()
	if err != nil {
		return errors.Wrap(err, "retrieving image layers")
	}

	layers = append(layers, static.NewLayer(configRaw, mediaType))

	for i := len(layers) - 1; i >= 0; i-- {
		if err := copyLayerToTar(tw, layers[i]); err != nil {
			return err
		}
	}

	return nil
}

func copyLayerToTar(tw *tar.Writer, layer v1.Layer) error {
	dgst, err := layer.Digest()
	if err != nil {
		return errors.Wrap(err, "reading layer digest failed")
	}

	size, err := layer.Size()
	if err != nil {
		return errors.Wrap(err, "reading layer digest failed")
	}

	r, err := layer.Compressed()
	if err != nil {
		return errors.Wrap(err, "reading layer contents")
	}

	defer func() {
		_ = r.Close()
	}()

	return copyToTar(tw, r, tar.Header{
		Name: filepath.Join("blobs", dgst.Algorithm, dgst.Hex),
		Size: size,
	})
}

func copyToTar(tw *tar.Writer, r io.Reader, header tar.Header) error {
	header.Mode = 0644
	if err := tw.WriteHeader(&header); err != nil {
		return err
	}
	if _, err := io.CopyN(tw, r, header.Size); err != nil {
		return err
	}
	return nil
}
