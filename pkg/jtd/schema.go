package jtd

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/innoai-tech/worklist/pkg/collection/ordered"
	"sort"

	"github.com/stretchr/objx"
)

type Schema interface {
	fmt.Stringer
	Meta() map[string]any
	Defs() map[string]Schema
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

func (a *Any) String() string {
	return "any"
}

type Type string

const (
	TypeBoolean   Type = "boolean"
	TypeString    Type = "string"
	TypeTimestamp Type = "timestamp"

	TypeFloat32 Type = "float32"
	TypeFloat64 Type = "float64"

	TypeInt8  Type = "int8"
	TypeInt16 Type = "int16"
	TypeInt32 Type = "int32"
	TypeInt64 Type = "int64"

	TypeUint8  Type = "uint8"
	TypeUint16 Type = "uint16"
	TypeUint32 Type = "uint32"
	TypeUint64 Type = "uint64"
)

// Basic
// https://jsontypedef.com/docs/jtd-in-5-minutes/#type-schemas
type Basic struct {
	Type Type `json:"type"`

	Common
}

func (b *Basic) String() string {
	return string(b.Type)
}

// Enum
// https://jsontypedef.com/docs/jtd-in-5-minutes/#enum-schemas
type Enum struct {
	Enum []any `json:"enum"`

	Common
}

func (e *Enum) String() string {
	b := bytes.NewBuffer(nil)

	enc := json.NewEncoder(b)

	for i, v := range e.Enum {
		if i > 0 {
			_, _ = fmt.Fprintf(b, " | ")
		}
		_ = enc.Encode(v)
	}

	return b.String()
}

// List
// https://jsontypedef.com/docs/jtd-in-5-minutes/#elements-schemas
type List struct {
	Elements Schema `json:"elements"`

	Common
}

func (e *List) String() string {
	return fmt.Sprintf("List<%s>", e.Elements)
}

// Object
// https://jsontypedef.com/docs/jtd-in-5-minutes/#properties-schemas
type Object struct {
	Properties           *ordered.Map[string, Schema] `json:"properties,omitempty"`
	OptionalProperties   *ordered.Map[string, Schema] `json:"optionalProperties,omitempty"`
	AdditionalProperties bool                         `json:"additionalProperties,omitempty"`

	Common
}

func (e *Object) String() string {
	b := bytes.NewBufferString("{ ")

	idx := 0

	for e := range e.Properties.Iter(context.Background()) {
		if idx > 0 {
			b.WriteString(", ")
		}

		b.WriteString(e.Key)
		b.WriteString(": ")
		b.WriteString(e.Value.String())

		idx++
	}

	for e := range e.OptionalProperties.Iter(context.Background()) {
		if idx > 0 {
			b.WriteString(", ")
		}

		b.WriteString(e.Key)
		b.WriteString("?: ")
		b.WriteString(e.Value.String())

		idx++
	}

	b.WriteString(" }")

	return b.String()
}

func (o *Object) SetProperty(name string, s Schema) {
	if o.Properties == nil {
		o.Properties = &ordered.Map[string, Schema]{}
	}
	o.Properties.Set(name, s)
}

// Map
// https://jsontypedef.com/docs/jtd-in-5-minutes/#values-schemas
type Map struct {
	Values Schema `json:"values,omitempty"`

	// ex sames as json schema
	PropertyNames Schema `json:"propertyNames,omitempty"`

	Common
}

func (e *Map) String() string {
	return fmt.Sprintf("Map<%s,%s>", e.PropertyNames, e.Values)
}

// TaggedUnion
// https://jsontypedef.com/docs/jtd-in-5-minutes/#properties-schemas
type TaggedUnion struct {
	Discriminator string             `json:"discriminator"`
	Mapping       map[string]*Object `json:"mapping"`

	Common
}

func (t *TaggedUnion) String() string {

	keys := make([]string, 0, len(t.Mapping))
	for k := range t.Mapping {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	b := bytes.NewBuffer(nil)

	for i, key := range keys {
		if i > 0 {
			b.WriteString(" | ")
		}
		b.WriteString(fmt.Sprintf("({ %s: %q } & %s)", t.Discriminator, key, t.Mapping[key]))
	}

	return b.String()
}

type Ref struct {
	Ref string `json:"ref"`

	Common
}

func (ref Ref) String() string {
	return ref.Ref
}

type Common struct {
	Metadata     map[string]any               `json:"metadata,omitempty"`
	Nullable     bool                         `json:"nullable,omitempty"`
	DefaultValue any                          `json:"defaultValue,omitempty"`
	Definitions  *ordered.Map[string, Schema] `json:"definitions,omitempty"`
	ID           string                       `json:"-"`
}

func (c *Common) Meta() map[string]any {
	return c.Metadata
}

func (c *Common) Defs() map[string]Schema {
	if c.Definitions != nil && c.Definitions.Len() != 0 {
		defs := make(map[string]Schema)
		for e := range c.Definitions.Iter(context.Background()) {
			defs[e.Key] = e.Value
		}
		return defs
	}
	return nil
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
		c.Definitions = &ordered.Map[string, Schema]{}
	}
	c.Definitions.Set(name, s)
}

func (c *Common) SetNullable(nullable bool) {
	c.Nullable = nullable
}
