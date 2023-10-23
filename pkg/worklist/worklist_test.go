package worklist_test

import (
	"context"
	"fmt"
	"github.com/google/go-containerregistry/pkg/authn"
	"github.com/google/go-containerregistry/pkg/crane"
	"github.com/innoai-tech/worklist/pkg/artifact"
	"os"
	"path"
	"testing"

	testingx "github.com/octohelm/x/testing"

	"github.com/innoai-tech/worklist/pkg/worklist/loader"
)

func TestLoad(t *testing.T) {
	registry := os.Getenv("CONTAINER_REGISTRY")

	registryAuth := authn.FromConfig(authn.AuthConfig{
		Username: os.Getenv("CONTAINER_REGISTRY_USERNAME"),
		Password: os.Getenv("CONTAINER_REGISTRY_PASSWORD"),
	})

	cwd, _ := os.Getwd()

	c, err := loader.Load(context.Background(), loader.WithWorkingDir(path.Join(cwd, "../../testdata/example")))
	testingx.Expect(t, err, testingx.Be[error](nil))

	img, err := c.Build(artifact.WithTag(fmt.Sprintf("%s/worklist/example", registry)))
	testingx.Expect(t, err, testingx.Be[error](nil))

	configRaw, _ := img.RawConfigFile()
	fmt.Println(string(configRaw))

	t.Run("Push", func(t *testing.T) {
		err := crane.Push(
			img,
			fmt.Sprintf("%s/worklist/example", registry),
			crane.WithAuth(registryAuth),
		)
		testingx.Expect(t, err, testingx.Be[error](nil))

		raw, _ := img.RawManifest()
		fmt.Println(string(raw))
	})

	t.Run("Pull", func(t *testing.T) {
		pulled, err := crane.Pull(
			fmt.Sprintf("%s/worklist/example", registry),
			crane.WithAuth(registryAuth),
		)
		testingx.Expect(t, err, testingx.Be[error](nil))

		c, _ := pulled.RawConfigFile()
		fmt.Println(string(c))

		m, _ := pulled.Manifest()

		for _, l := range m.Layers {
			layer, _ := pulled.LayerByDigest(l.Digest)
			d, _ := layer.Digest()
			testingx.Expect(t, l.Digest, testingx.Be(d))
		}
	})
}
