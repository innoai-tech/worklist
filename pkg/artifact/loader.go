package artifact

import (
	"context"
	"io"
	"mime"
	"os"
	"path/filepath"
	"sort"

	"github.com/octohelm/unifs/pkg/filesystem"
	"github.com/octohelm/unifs/pkg/filesystem/local"
	contextx "github.com/octohelm/x/context"
	"github.com/opencontainers/go-digest"
	"github.com/pkg/errors"
)

var TheLoader = contextx.New[Loader](contextx.WithDefaultsFunc(func() Loader {
	return NewLoader()
}))

type Loader interface {
	Load(ctx context.Context, path string) (Artifact, error)
	Artifacts() []Artifact
}

func WithFS(fs filesystem.FileSystem) OptionFunc {
	return func(o *loader) {
		o.fs = fs
	}
}

type OptionFunc = func(o *loader)

func NewLoader(fns ...OptionFunc) Loader {
	l := &loader{
		fs:        local.NewLocalFS(""),
		artifacts: map[string]Artifact{},
	}

	for _, f := range fns {
		f(l)
	}

	return l
}

type loader struct {
	fs        filesystem.FileSystem
	artifacts map[string]Artifact
}

func (c *loader) Load(ctx context.Context, path string) (Artifact, error) {
	if a, ok := c.artifacts[path]; ok {
		return a, nil
	}

	info, err := c.fs.Stat(ctx, path)
	if err != nil {
		return nil, err
	}
	if info.IsDir() {
		return nil, errors.New("need a file, but got dir")
	}

	a, err := FromOpener(MediaTypeOf(path), func() (io.ReadCloser, error) {
		return c.fs.OpenFile(ctx, path, os.O_RDONLY, os.ModePerm)
	})
	if err != nil {
		return nil, err
	}

	c.artifacts[path] = a

	return a, nil
}

func MediaTypeOf(filename string) string {
	ext := filepath.Ext(filename)
	if ext != "" {
		return mime.TypeByExtension(ext)
	}
	return "application/octet-stream"
}

type asset struct {
	fs       filesystem.FileSystem
	filename string
	dgst     *digest.Digest
}

func (a *asset) MediaType() string {
	ext := filepath.Ext(a.filename)
	if ext != "" {
		return mime.TypeByExtension(ext)
	}
	return "application/octet-stream"
}

func (c *loader) Artifacts() []Artifact {
	paths := make([]string, 0, len(c.artifacts))
	for p := range c.artifacts {
		paths = append(paths, p)
	}
	sort.Strings(paths)

	artifacts := make([]Artifact, len(paths))

	for i := range artifacts {
		artifacts[i] = c.artifacts[paths[i]]
	}

	return artifacts
}
