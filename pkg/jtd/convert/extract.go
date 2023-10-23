package convert

import (
	"context"
	"reflect"
	"regexp"
	"strings"

	"golang.org/x/mod/module"

	"github.com/innoai-tech/worklist/pkg/collection"
	"github.com/innoai-tech/worklist/pkg/collection/ordered"
	"github.com/innoai-tech/worklist/pkg/jtd"
)

var re = regexp.MustCompile(`[\-./]`)

func safePrefix(pkgPath string) string {
	if strings.HasPrefix(pkgPath, "github.com/") {
		pkgPath = pkgPath[len("github.com/"):]
	}

	parts := strings.Split(pkgPath, "/pkg/")

	if len(parts) > 1 {
		return re.ReplaceAllString(parts[1], "_")
	}

	return re.ReplaceAllString(parts[0], "_")
}

func Extract(t reflect.Type) jtd.Schema {
	ex := &extractor{
		definitions: map[string]jtd.Schema{},
		nameTags:    []string{"json"},
		refName: func(name string, pkgPath string) string {
			if pkgPath == "" {
				return name
			}
			prefix, pathMajor, ok := module.SplitPathVersion(pkgPath)
			if ok && pathMajor != "" {
				return safePrefix(prefix) + "_" + name + "_" + pathMajor
			}
			return safePrefix(pkgPath) + "_" + name
		},
	}

	root := ex.SchemaOf(t)

	if ref, ok := root.(*jtd.Ref); ok {
		root = ex.definitions[ref.Ref]
		delete(ex.definitions, ref.Ref)
	}

	for n, s := range ex.definitions {
		root.(jtd.SchemaModifier).SetDefinition(n, s)
	}

	return root
}

type extractor struct {
	definitions map[string]jtd.Schema
	nameTags    []string
	refName     func(name string, pkgPath string) string
}

func (e *extractor) SchemaOf(t reflect.Type) (s jtd.Schema) {
	if pkgPath := t.PkgPath(); pkgPath != "" {
		defer func() {
			ref := e.refName(t.Name(), t.PkgPath())
			if _, ok := e.definitions[ref]; !ok {
				e.definitions[ref] = s
			}
			s = &jtd.Ref{
				Ref: ref,
			}
		}()
	}

	switch t.Kind() {
	case reflect.String:
		return &jtd.Basic{
			Type: jtd.TypeString,
		}
	case reflect.Bool:
		return &jtd.Basic{
			Type: jtd.TypeBoolean,
		}
	case reflect.Float32:
		return &jtd.Basic{
			Type: jtd.TypeFloat32,
		}
	case reflect.Float64:
		return &jtd.Basic{
			Type: jtd.TypeFloat64,
		}
	case reflect.Int64:
		return &jtd.Basic{
			Type: jtd.TypeInt64,
		}
	case reflect.Int, reflect.Int32:
		return &jtd.Basic{
			Type: jtd.TypeInt32,
		}
	case reflect.Int16:
		return &jtd.Basic{
			Type: jtd.TypeInt16,
		}
	case reflect.Int8:
		return &jtd.Basic{
			Type: jtd.TypeInt8,
		}
	case reflect.Uint64:
		return &jtd.Basic{
			Type: jtd.TypeUint64,
		}
	case reflect.Uint, reflect.Uint32:
		return &jtd.Basic{
			Type: jtd.TypeUint32,
		}
	case reflect.Uint16:
		return &jtd.Basic{
			Type: jtd.TypeUint16,
		}
	case reflect.Uint8:
		return &jtd.Basic{
			Type: jtd.TypeUint8,
		}
	case reflect.Map:
		return &jtd.Map{
			Values:        e.SchemaOf(t.Elem()),
			PropertyNames: e.SchemaOf(t.Key()),
		}
	case reflect.Ptr:
		return e.SchemaOf(t.Elem())
	case reflect.Slice:
		return &jtd.List{
			Elements: e.SchemaOf(t.Elem()),
		}
	case reflect.Struct:
		o := &jtd.Object{}

		for sf := range collection.IterStructField(context.Background(), reflect.New(t)) {
			if sf.Optional {
				if o.OptionalProperties == nil {
					o.OptionalProperties = &ordered.Map[string, jtd.Schema]{}
				}
				o.OptionalProperties.Set(sf.Name, e.SchemaOf(sf.Type))
			} else {
				if o.Properties == nil {
					o.Properties = &ordered.Map[string, jtd.Schema]{}
				}
				o.Properties.Set(sf.Name, e.SchemaOf(sf.Type))
			}
		}
		return o
	default:
		return &jtd.Any{}
	}
}
