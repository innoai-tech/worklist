package loader

import (
	"bytes"
	"context"
	"fmt"
	"github.com/octohelm/unifs/pkg/filesystem"
	"io"
	"io/fs"
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

func loadGraphQlTo(ctx context.Context, w io.Writer, fs filesystem.FileSystem, filename string) error {
	f, err := fs.OpenFile(ctx, filename, os.O_RDONLY, os.ModePerm)
	if err != nil {
		return errors.Wrap(err, "open file failed")
	}

	defer f.Close()
	_, err = io.Copy(w, f)
	if err != nil {
		return errors.Wrap(err, "read failed")
	}
	return nil
}

func Load(ctx context.Context, optFns ...OptionFunc) (*worklist.WorkList, error) {
	l := &loader{
		entrypoint:  "schema.gql",
		definitions: map[string]jtd.Schema{},
	}

	for _, fn := range optFns {
		fn(l)
	}

	fsys := local.NewFS(l.workingDir)
	l.converter = md.NewConverter(md.WithFS(fsys))

	files := make([]string, 0)

	if err := filesystem.WalkDir(ctx, fsys, ".", func(path string, d fs.DirEntry, err error) error {
		if d.IsDir() && path != "." {
			return fs.SkipDir
		}

		if strings.HasSuffix(path, ".gql") && !strings.HasSuffix(path, ".d.gql") {
			files = append(files, path)
		}

		return nil
	}); err != nil {
		return nil, err
	}

	buf := bytes.NewBuffer(nil)

	for _, f := range files {
		if err := loadGraphQlTo(ctx, buf, fsys, f); err != nil {
			return nil, err
		}
	}

	params := parser.ParseParams{
		Source: &source.Source{
			Body: buf.Bytes(),
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

	schema, err := l.Named("FormData", true)
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

func (ldr *loader) NamedType(name string) (ast.Node, error) {
	for i := range ldr.doc.Definitions {
		switch x := ldr.doc.Definitions[i].(type) {
		case *ast.ObjectDefinition:
			if name == x.Name.Value {
				return x, nil
			}
		case *ast.InputObjectDefinition:
			if name == x.Name.Value {
				return x, nil
			}
		case *ast.EnumDefinition:
			if name == x.Name.Value {
				return x, nil
			}
		case *ast.InterfaceDefinition:
			if name == x.Name.Value {
				return x, nil
			}
		case *ast.UnionDefinition:
			if name == x.Name.Value {
				return x, nil
			}
		default:
			return nil, errors.Errorf("unsupported %T", x)
		}
	}

	return nil, errors.Errorf("undefined %s", name)
}

func (ldr *loader) Named(name string, decl bool) (tpe jtd.Schema, err error) {
	if decl {
		if t, ok := ldr.definitions[name]; ok {
			return t, nil
		}

		defer func() {
			ldr.definitions[name] = tpe
		}()
	}

	namedType, err := ldr.NamedType(name)
	if err != nil {
		return nil, err
	}

	return ldr.SchemaFromAST(namedType)
}

func (ldr *loader) SchemaFromASTWithRequired(node ast.Node) (jtd.Schema, bool, error) {
	switch x := node.(type) {
	case *ast.NonNull:
		s, err := ldr.SchemaFromAST(x.Type)
		return s, true, err
	}
	s, err := ldr.SchemaFromAST(node)
	return s, false, err
}

func (ldr *loader) SchemaFromAST(node ast.Node) (jtd.Schema, error) {
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
			_, err := ldr.Named(typeOrRef, true)
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

		if err := ldr.ModifierDescription(e, x.Description); err != nil {
			return nil, err
		}

		return e, nil
	case *ast.List:
		e, err := ldr.SchemaFromAST(x.Type)
		if err != nil {
			return nil, err
		}
		return &jtd.List{Elements: e}, nil
	case *ast.InterfaceDefinition:
		o := &jtd.Object{}
		o.ID = x.Name.Value

		for _, f := range x.Fields {
			s, required, err := ldr.SchemaFromASTWithRequired(f.Type)
			if err != nil {
				return nil, err
			}

			if !required {
				s.(jtd.SchemaModifier).SetNullable(true)
			}

			if err := ldr.ModifyMetadataFromField(s.(jtd.SchemaModifier), f.Description, f.Directives); err != nil {
				return nil, err
			}

			o.SetProperty(f.Name.Value, s)
		}

		if err := ldr.ModifierDescription(o, x.Description); err != nil {
			return nil, err
		}
		return o, nil
	case *ast.InputObjectDefinition:
		o := &jtd.Object{}
		o.ID = x.Name.Value

		for _, f := range x.Fields {
			s, required, err := ldr.SchemaFromASTWithRequired(f.Type)
			if err != nil {
				return nil, err
			}

			if !required {
				s.(jtd.SchemaModifier).SetNullable(true)
			}

			if err := ldr.ModifyMetadataFromField(s.(jtd.SchemaModifier), f.Description, f.Directives); err != nil {
				return nil, err
			}

			o.SetProperty(f.Name.Value, s)
		}

		if err := ldr.ModifierDescription(o, x.Description); err != nil {
			return nil, err
		}
		return o, nil
	case *ast.ObjectDefinition:
		o := &jtd.Object{}
		o.ID = x.Name.Value

		interfaceFields := map[string]*ast.FieldDefinition{}

		for _, i := range x.Interfaces {
			f, err := ldr.NamedType(i.Name.Value)
			if err != nil {
				return nil, err
			}

			ii := f.(*ast.InterfaceDefinition)
			for _, iiField := range ii.Fields {
				interfaceFields[iiField.Name.Value] = iiField
			}
		}

		for _, f := range x.Fields {
			s, required, err := ldr.SchemaFromASTWithRequired(f.Type)
			if err != nil {
				return nil, err
			}

			if !required {
				s.(jtd.SchemaModifier).SetNullable(true)
			}

			if len(f.Arguments) > 0 {
				for _, arg := range f.Arguments {
					if arg.Name.Value == "of" && arg.DefaultValue != nil {
						s.(jtd.SchemaModifier).SetMeta("discriminatorValue", arg.DefaultValue.GetValue())
						if description := arg.Description; description != nil {
							s.(jtd.SchemaModifier).SetMeta("discriminatorLabel", description.Value)
						} else if fieldDescription := f.Description; fieldDescription != nil {
							s.(jtd.SchemaModifier).SetMeta("discriminatorLabel", fieldDescription.Value)
							// when use as discriminatorLabel
							// should delete
							f.Description = nil
						} else {
							s.(jtd.SchemaModifier).SetMeta("discriminatorLabel", "")
						}
					}
				}
			}

			d := f.Description
			if d == nil {
				// reuse desc from interfaces
				if iff, ok := interfaceFields[f.Name.Value]; ok {
					d = iff.Description
				}
			}

			directives := f.Directives

			// merge directives from interfaces
			if iff, ok := interfaceFields[f.Name.Value]; ok {
				directives = append(directives, iff.Directives...)
			}

			if err := ldr.ModifyMetadataFromField(s.(jtd.SchemaModifier), d, directives); err != nil {
				return nil, err
			}

			o.SetProperty(f.Name.Value, s)
		}

		if err := ldr.ModifierDescription(o, x.Description); err != nil {
			return nil, err
		}
		return o, nil
	case *ast.UnionDefinition:
		tu := &jtd.TaggedUnion{
			Discriminator: "",
			Mapping:       map[string]*jtd.Object{},
		}

		mappingLabels := map[string]string{}

		for _, named := range x.Types {
			s, err := ldr.Named(named.Name.Value, false)
			if err != nil {
				return nil, err
			}

			o, ok := s.(*jtd.Object)
			if ok {
				for e := range o.Properties.Iter(context.Background()) {
					if discriminatorValue, ok := e.Value.Meta()["discriminatorValue"]; ok {
						if discriminatorStringValue, ok := discriminatorValue.(string); ok {
							if tu.Discriminator == "" {
								tu.Discriminator = e.Key
							}

							if e.Key != tu.Discriminator {
								panic(errors.Errorf("%s: invalid tagged union, discriminator should be %s but got %s", named.Name.Value, tu.Discriminator, e.Key))
							}

							for key, value := range e.Value.Meta() {
								switch key {
								case "discriminatorValue":
									continue
								case "discriminatorLabel":
									mappingLabels[discriminatorStringValue] = value.(string)
									continue
								}
								tu.SetMeta(fmt.Sprintf("discriminator.metadata.%s", key), value)
							}

							o.Properties.Delete(e.Key)

							tu.Mapping[discriminatorStringValue] = o

							break
						}
					}
				}
				continue
			}

			panic(errors.New("tagged union must supported object as mapping"))
		}

		tu.SetMeta("mappingLabels", mappingLabels)

		if err := ldr.ModifierDescription(tu, x.Description); err != nil {
			return nil, err
		}
		return tu, nil
	default:

	}
	return nil, nil
}

const inputByPrefix = "input_by_"

func (ldr *loader) ModifyMetadataFromField(modifier jtd.SchemaModifier, doc *ast.StringValue, directives []*ast.Directive) error {
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

	return ldr.ModifierDescription(modifier, doc)
}

func (ldr *loader) ModifierDescription(modifier jtd.SchemaModifier, doc *ast.StringValue) error {
	ctx := context.Background()
	ctx = md.TheConverter.Inject(ctx, ldr.converter)

	if doc != nil {
		parts := strings.SplitN(strings.TrimSpace(doc.Value), "\n", 2)

		f := &field.Field{}
		f.Label = strings.TrimSpace(parts[0])

		if len(parts) == 2 {
			f.Description = strings.TrimSpace(parts[1])
		}

		if err := f.PostProcess(ctx, ldr.entrypoint); err != nil {
			return err
		}

		for k, v := range toValues(f) {
			modifier.SetMeta(k, v)
		}
	}
	return nil
}

func toValues(v any) map[string]any {
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

type PostProcessor interface {
	PostProcess(ctx context.Context, filename string) error
}
