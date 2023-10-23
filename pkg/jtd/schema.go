package jtd

import (
	"github.com/innoai-tech/worklist/pkg/collection"
	"github.com/stretchr/objx"
)

type Schema interface {
	Meta() map[string]any
}

type SchemaModifier interface {
	SetMeta(k string, v any)
	SetDefinition(n string, s Schema)
	SetNullable(nullable bool)
}

// Any
// https://jsontypedef.com/docs/jtd-in-5-minutes/#empty-schemas
type Any struct {
	Common
}

// Basic
// https://jsontypedef.com/docs/jtd-in-5-minutes/#type-schemas
type Basic struct {
	Type string `json:"type"`

	Common
}

// Enum
// https://jsontypedef.com/docs/jtd-in-5-minutes/#enum-schemas
type Enum struct {
	Enum []any `json:"enum"`

	Common
}

// List
// https://jsontypedef.com/docs/jtd-in-5-minutes/#elements-schemas
type List struct {
	Elements Schema `json:"elements"`

	Common
}

// Object
// https://jsontypedef.com/docs/jtd-in-5-minutes/#properties-schemas
type Object struct {
	Properties           *collection.OrderedMap[string, Schema] `json:"properties,omitempty"`
	OptionalProperties   *collection.OrderedMap[string, Schema] `json:"optionalProperties,omitempty"`
	AdditionalProperties bool                                   `json:"additionalProperties,omitempty"`

	Common
}

func (o *Object) SetProperty(name string, s Schema) {
	if o.Properties == nil {
		o.Properties = &collection.OrderedMap[string, Schema]{}
	}
	o.Properties.Set(name, s)
}

// Map
// https://jsontypedef.com/docs/jtd-in-5-minutes/#values-schemas
type Map struct {
	Values Schema `json:"values,omitempty"`

	Common
}

// TaggedUnion
// https://jsontypedef.com/docs/jtd-in-5-minutes/#properties-schemas
type TaggedUnion struct {
	Discriminator string            `json:"discriminator"`
	Mapping       map[string]Object `json:"mapping"`

	Common
}

type Ref struct {
	Ref string `json:"ref"`

	Common
}

type Common struct {
	Metadata    map[string]any                         `json:"metadata,omitempty"`
	Nullable    bool                                   `json:"nullable,omitempty"`
	Definitions *collection.OrderedMap[string, Schema] `json:"definitions,omitempty"`
	ID          string                                 `json:"-"`
}

func (c Common) Meta() map[string]any {
	return c.Metadata
}

var _ SchemaModifier = &Common{}

func (c *Common) SetMeta(keyPath string, v any) {
	if c.Metadata == nil {
		c.Metadata = map[string]any{}
	}
	objx.Map(c.Metadata).Set(keyPath, v)
}

func (c *Common) SetDefinition(name string, s Schema) {
	if c.Definitions == nil {
		c.Definitions = &collection.OrderedMap[string, Schema]{}
	}
	c.Definitions.Set(name, s)
}

func (c *Common) SetNullable(nullable bool) {
	c.Nullable = nullable
}
