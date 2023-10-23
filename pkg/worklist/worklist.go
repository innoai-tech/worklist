package worklist

import (
	"encoding/json"

	v1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/innoai-tech/worklist/pkg/artifact"
	"github.com/innoai-tech/worklist/pkg/jtd"
)

type WorkList struct {
	Schema    jtd.Schema
	Artifacts []artifact.Artifact
}

func (w *WorkList) Build(optionFuncs ...artifact.BuildOptionFunc) (v1.Image, error) {
	raw, err := json.Marshal(w.Schema)
	if err != nil {
		return nil, err
	}
	return BuildSchema(raw, w.Artifacts, append(optionFuncs, artifact.WithAnnotations(map[string]string{
		"worklist.displayName": func() string {
			meta := w.Schema.Meta()
			if meta != nil {
				if label, ok := meta["label"].(string); ok {
					return label
				}
			}
			return ""
		}(),
	}))...)
}
