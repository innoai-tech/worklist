package loader

import (
	"context"

	"os"
	"reflect"
	"strings"

	"github.com/graphql-go/graphql/language/ast"
	"github.com/graphql-go/graphql/language/parser"
	"github.com/graphql-go/graphql/language/source"
	"github.com/octohelm/unifs/pkg/filesystem/local"
	reflectx "github.com/octohelm/x/reflect"
	"github.com/pkg/errors"

	"github.com/innoai-tech/worklist/pkg/collection"
	"github.com/innoai-tech/worklist/pkg/fsutil"
	"github.com/innoai-tech/worklist/pkg/jtd"
	"github.com/innoai-tech/worklist/pkg/md"
	"github.com/innoai-tech/worklist/pkg/worklist"
	"github.com/innoai-tech/worklist/pkg/worklist/field"
	_ "github.com/innoai-tech/worklist/pkg/worklist/field"
	"github.com/innoai-tech/worklist/pkg/worklist/gql"
)

func WithWorkingDir(wd string) OptionFunc {
	return func(l *loader) {
		l.workingDir = wd
	}
}

type OptionFunc func(l *loader)

func Load(ctx context.Context, optFns ...OptionFunc) (*worklist.WorkList, error) {
	l := &loader{
		entrypoint: "schema.gql",
	}

	for _, fn := range optFns {
		fn(l)
	}

	fs := local.NewLocalFS(l.workingDir)
	l.converter = md.NewConverter(md.WithFS(fs))

	f, err := fs.OpenFile(ctx, l.entrypoint, os.O_RDONLY, os.ModePerm)
	if err != nil {
		return nil, errors.Wrap(err, "open file failed")
	}
	data, err := fsutil.ReadAll(f)
	if err != nil {
		return nil, errors.Wrap(err, "read failed")
	}

	params := parser.ParseParams{
		Source: &source.Source{
			Body: data,
		},
		Options: parser.ParseOptions{
			NoSource:   true,
			NoLocation: true,
		},
	}

	doc, err := parser.Parse(params)
	if err != nil {
		return nil, errors.Wrap(err, "parse failed")
	}

	l.doc = doc

	schema, err := l.Named("FormData")
	if err != nil {
		return nil, err
	}

	for name := range l.definitions {
		if name != "FormData" {
			schema.(jtd.SchemaModifier).SetDefinition(name, l.definitions[name])
		}
	}

	return &worklist.WorkList{
		Schema:    schema,
		Artifacts: l.converter.Artifacts(),
	}, nil
}

type Context struct {
	Definitions map[string]jtd.Schema
}

type loader struct {
	workingDir  string
	entrypoint  string
	doc         *ast.Document
	definitions map[string]jtd.Schema
	converter   md.Converter
}

func (r *loader) Named(name string) (tpe jtd.Schema, err error) {
	if r.definitions[name] == nil {
		r.definitions = map[string]jtd.Schema{}
	}

	if t, ok := r.definitions[name]; ok {
		return t, nil
	}

	defer func() {
		r.definitions[name] = tpe
	}()

	for i := range r.doc.Definitions {
		switch x := r.doc.Definitions[i].(type) {
		case *ast.ObjectDefinition:
			if name == x.Name.Value {
				return r.SchemaFromAST(x)
			}
		case *ast.InputObjectDefinition:
			if name == x.Name.Value {
				return r.SchemaFromAST(x)
			}
		case *ast.EnumDefinition:
			if name == x.Name.Value {
				return r.SchemaFromAST(x)
			}
		}
	}

	return
}

func (r *loader) SchemaFromASTWithRequired(node ast.Node) (jtd.Schema, bool, error) {
	switch x := node.(type) {
	case *ast.NonNull:
		s, err := r.SchemaFromAST(x.Type)
		return s, true, err
	}
	s, err := r.SchemaFromAST(node)
	return s, false, err
}

func (r *loader) SchemaFromAST(node ast.Node) (jtd.Schema, error) {
	switch x := node.(type) {
	case *ast.Named:
		switch typeOrRef := x.Name.Value; typeOrRef {
		case "Any":
			return &jtd.Any{}, nil
		case "ID", "String":
			return &jtd.Basic{Type: "string"}, nil
		case "Timestamp":
			return &jtd.Basic{Type: "timestamp"}, nil
		case "Boolean":
			return &jtd.Basic{Type: "boolean"}, nil
		case "Int", "Int32":
			return &jtd.Basic{Type: "int32"}, nil
		case "Int8":
			return &jtd.Basic{Type: "int8"}, nil
		case "Int16":
			return &jtd.Basic{Type: "int16"}, nil
		case "Unit", "Unit32":
			return &jtd.Basic{Type: "unit32"}, nil
		case "Uint8":
			return &jtd.Basic{Type: "uint8"}, nil
		case "Uint16":
			return &jtd.Basic{Type: "uint16"}, nil
		case "Float", "Float32":
			return &jtd.Basic{Type: "float32"}, nil
		case "Float64":
			return &jtd.Basic{Type: "float64"}, nil
		default:
			_, err := r.Named(typeOrRef)
			if err != nil {
				return nil, err
			}
			return &jtd.Ref{Ref: typeOrRef}, nil
		}
	case *ast.EnumDefinition:
		enums := make([]any, len(x.Values))
		enumLabels := make([]string, len(x.Values))

		for i, v := range x.Values {
			enums[i] = v.Name.Value

			if v.Description != nil {
				enumLabels[i] = v.Description.Value
			}
		}

		e := &jtd.Enum{Enum: enums}
		e.SetMeta("enumLabels", enumLabels)
		return e, nil
	case *ast.List:
		e, err := r.SchemaFromAST(x.Type)
		if err != nil {
			return nil, err
		}
		return &jtd.List{Elements: e}, nil
	case *ast.ObjectDefinition:
		o := &jtd.Object{}
		o.ID = x.Name.Value

		for _, f := range x.Fields {
			s, required, err := r.SchemaFromASTWithRequired(f.Type)
			if err != nil {
				return nil, err
			}

			if !required {
				s.(jtd.SchemaModifier).SetNullable(true)
			}

			if err := r.ModifyMetadataFromField(s.(jtd.SchemaModifier), f.Description, f.Directives); err != nil {
				return nil, err
			}

			o.SetProperty(f.Name.Value, s)
		}

		return o, nil
	case *ast.InputObjectDefinition:
		o := &jtd.Object{}
		o.ID = x.Name.Value

		for _, f := range x.Fields {
			s, required, err := r.SchemaFromASTWithRequired(f.Type)
			if err != nil {
				return nil, err
			}

			if !required {
				s.(jtd.SchemaModifier).SetNullable(true)
			}

			if err := r.ModifyMetadataFromField(s.(jtd.SchemaModifier), f.Description, f.Directives); err != nil {
				return nil, err
			}

			o.SetProperty(f.Name.Value, s)
		}

		return o, nil
	default:

	}
	return nil, nil
}

const inputByPrefix = "input_by_"

func (r *loader) ModifyMetadataFromField(modifier jtd.SchemaModifier, doc *ast.StringValue, directives []*ast.Directive) error {
	ctx := context.Background()

	ctx = md.TheConverter.Inject(ctx, r.converter)

	toValues := func(v any) map[string]any {
		values := map[string]any{}
		for sf := range collection.IterStructField(context.Background(), reflect.ValueOf(v)) {
			if sf.Name == "Name" && sf.Type.Kind() == reflect.Struct {
				continue
			}

			v := sf.Value.Interface()
			if sf.Optional && reflectx.IsEmptyValue(v) {
				continue
			}
			values[sf.Name] = v
		}
		return values
	}

	for _, d := range directives {
		name := d.Name.Value

		d, err := gql.UnmarshalDirective(name, d.Arguments)
		if err != nil {
			return err
		}

		inputBy := toValues(d)

		if strings.HasPrefix(name, inputByPrefix) {
			inputBy["kind"] = strings.ReplaceAll(name[len(inputByPrefix):], "_", "-")
			modifier.SetMeta("inputBy", inputBy)
		} else {
			modifier.SetMeta(name, inputBy)
		}
	}

	if doc != nil {
		parts := strings.SplitN(strings.TrimSpace(doc.Value), "\n", 2)

		f := &field.Field{}
		f.Label = strings.TrimSpace(parts[0])

		if len(parts) == 2 {
			f.Description = strings.TrimSpace(parts[1])
		}

		if err := f.PostProcess(ctx, r.entrypoint); err != nil {
			return err
		}

		for k, v := range toValues(f) {
			modifier.SetMeta(k, v)
		}
	}

	return nil
}

type PostProcessor interface {
	PostProcess(ctx context.Context, filename string) error
}
