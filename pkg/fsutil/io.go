package fsutil

import (
	"context"
	"io"
	"os"
	"path/filepath"
	"syscall"

	"github.com/octohelm/unifs/pkg/filesystem"
)

func ReadAll(r io.ReadCloser) ([]byte, error) {
	defer r.Close()
	return io.ReadAll(r)
}

func WriteFile(ctx context.Context, fs filesystem.FileSystem, filename string, r io.Reader) error {
	d := filepath.Dir(filename)

	if d != "" && d != "." {
		if err := MkdirAll(ctx, fs, d, os.ModeDir); err != nil {
			return err
		}
	}

	f, err := fs.OpenFile(ctx, filename, os.O_CREATE|os.O_RDWR, os.ModePerm)
	if err != nil {
		return err
	}
	defer f.Close()
	_, err = io.Copy(f, r)
	return err
}

func MkdirAll(ctx context.Context, fs filesystem.FileSystem, path string, perm os.FileMode) error {
	dir, err := fs.Stat(ctx, path)
	if err == nil {
		if dir.IsDir() {
			return nil
		}
		return &os.PathError{Op: "mkdir", Path: path, Err: syscall.ENOTDIR}
	}

	i := len(path)
	for i > 0 && os.IsPathSeparator(path[i-1]) { // Skip trailing path separator.
		i--
	}

	j := i
	for j > 0 && !os.IsPathSeparator(path[j-1]) { // Scan backward over element.
		j--
	}

	if j > 1 {
		err = MkdirAll(ctx, fs, path[:j-1], perm)

		if err != nil {
			return err
		}
	}

	// Parent now exists; invoke Mkdir and use its result.
	err = fs.Mkdir(ctx, path, perm)
	if err != nil {
		// Handle arguments like "foo/." by
		// double-checking that directory doesn't exist.
		dir, statErr := fs.Stat(ctx, path)
		if statErr == nil && dir.IsDir() {
			return nil
		}
		return err
	}
	return nil
}
