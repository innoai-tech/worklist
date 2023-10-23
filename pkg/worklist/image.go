package worklist

import (
	v1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/innoai-tech/worklist/pkg/artifact"
	specv1 "github.com/opencontainers/image-spec/specs-go/v1"
)

const (
	ConfigTypeV1 = "application/vnd.worklist.config.v1+json"
)

const (
	SchemaArtifactType   = "application/vnd.worklist.schema+type"
	FormDataArtifactType = "application/vnd.worklist.formdata+type"
)

func BuildSchema(raw []byte, artifacts []artifact.Artifact, optionFuncs ...artifact.BuildOptionFunc) (v1.Image, error) {
	a := &schemaArtifact{raw: raw}
	return artifact.ToImage(a, artifacts, optionFuncs...)
}

var _ artifact.Config = &schemaArtifact{}

type schemaArtifact struct {
	raw []byte
}

func (i *schemaArtifact) Platform() (*specv1.Platform, error) {
	return nil, nil
}

func (i *schemaArtifact) ArtifactType() (string, error) {
	return SchemaArtifactType, nil
}

func (i *schemaArtifact) ConfigMediaType() (string, error) {
	return ConfigTypeV1, nil
}

func (i *schemaArtifact) RawConfigFile() ([]byte, error) {
	return i.raw, nil
}
