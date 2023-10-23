package gql

import (
	"bytes"
	"context"
	"encoding/json"
	"reflect"
	"strconv"
	"strings"
	"time"

	"github.com/graphql-go/graphql"
	"github.com/graphql-go/graphql/language/ast"
	"github.com/pkg/errors"

	"github.com/innoai-tech/worklist/pkg/collection"
	"github.com/innoai-tech/worklist/pkg/worklist/gql/directive"
)

func NewSchemaConfig() graphql.SchemaConfig {
	return defaultCollector.ToSchemaConfig()
}

func RegisterDirective(d Directive) {
	defaultCollector.Register(d)
}

func UnmarshalDirective(name string, args []*ast.Argument) (Directive, error) {
	return defaultCollector.UnmarshalDirective(name, args)
}

var defaultCollector = &schemaConfigCollector{
	directives: map[string]Directive{},
	types:      map[string]Type{},
}

type Directive interface {
	Directive() *graphql.Directive
}

type Type interface {
	Type() graphql.Type
}

type schemaConfigCollector struct {
	types      map[string]Type
	directives map[string]Directive
}

func AsInput() OptionFunc {
	return func(o *configOption) {
		o.AsInput = true
	}
}

func Named(name string) OptionFunc {
	return func(o *configOption) {
		o.Name = name
	}
}

type configOption struct {
	Name    string
	AsInput bool
}

func configOptionFromFuncs(optionFns ...OptionFunc) *configOption {
	co := &configOption{}
	for i := range optionFns {
		optionFns[i](co)
	}
	return co
}

type OptionFunc = func(o *configOption)

func (c *schemaConfigCollector) Register(v any, optionFns ...OptionFunc) {
	rv, ok := v.(reflect.Value)
	if !ok {
		rv = reflect.ValueOf(v)
	}

	switch x := rv.Interface().(type) {
	case Directive:
		var nameConfig *directive.NameConfig

		for sf := range collection.IterStructField(context.Background(), rv) {
			if sf.Type.Name() == "Name" {
				nameConfig = &directive.NameConfig{
					Name: sf.Tag.Get("directive"),
					On:   strings.Split(sf.Tag.Get("on"), ","),
					Args: map[string]*graphql.ArgumentConfig{},
				}

				sf.Value.Addr().Interface().(directive.ConfigSetter).SetConfig(nameConfig)
				continue
			}

			if nameConfig == nil {
				continue
			}

			arg := &graphql.ArgumentConfig{}
			arg.Type = c.TypeOf(sf.Value, AsInput())

			if !sf.Optional {
				arg.Type = graphql.NewNonNull(arg.Type)
			}

			nameConfig.Args[sf.Name] = arg
		}

		if nameConfig != nil {
			c.directives[nameConfig.Name] = x
		}
	}
}

func (c *schemaConfigCollector) ToSchemaConfig() graphql.SchemaConfig {
	s := graphql.SchemaConfig{}
	s.Directives = make([]*graphql.Directive, 0, len(c.directives))
	s.Types = make([]graphql.Type, 0, len(c.types))

	for d := range collection.SortedIter(context.Background(), c.directives) {
		s.Directives = append(s.Directives, d.Directive())
	}

	for d := range collection.SortedIter(context.Background(), c.types) {
		s.Types = append(s.Types, d.Type())
	}

	return s
}

func (c *schemaConfigCollector) TypeOf(rv reflect.Value, optionFns ...OptionFunc) graphql.Type {
	v := rv.Interface()

	switch v.(type) {
	case *time.Time:
		return c.Scalar("Timestamp", graphql.ScalarConfig{
			ParseLiteral: func(valueAST ast.Value) interface{} {
				v := ToGoValue(valueAST)
				p, err := time.Parse(time.RFC3339, v.(string))
				if err != nil {
					panic(err)
				}
				return p
			},
			ParseValue: func(value interface{}) interface{} {
				p, err := time.Parse(time.RFC3339, v.(string))
				if err != nil {
					panic(err)
				}
				return p
			},
			Serialize: func(value interface{}) interface{} {
				return value.(*time.Time).Format(time.RFC3339)
			},
		})
	}

	switch rv.Kind() {
	case reflect.Ptr:
		return c.TypeOf(rv.Elem(), optionFns...)
	case reflect.Slice:
		return graphql.NewList(
			c.TypeOf(
				reflect.New(rv.Type().Elem()).Elem(),
				optionFns...,
			),
		)
	case reflect.Struct:
		tpeName := rv.Type().Name()
		if tpeName == "" {
			panic(errors.New("inline struct is not supported"))
		}

		opt := configOptionFromFuncs(optionFns...)

		if opt.AsInput {
			t := c.InputObject(tpeName, func() graphql.InputObjectConfig {
				fields := graphql.InputObjectConfigFieldMap{}

				for sf := range collection.IterStructField(context.Background(), rv) {
					field := &graphql.InputObjectFieldConfig{}
					field.Type = c.TypeOf(sf.Value, AsInput())
					if !sf.Optional {
						field.Type = graphql.NewNonNull(field.Type)
					}
					fields[sf.Name] = field
				}

				return graphql.InputObjectConfig{
					Fields: fields,
				}
			})

			return graphql.NewScalar(graphql.ScalarConfig{
				Name: t.Name(),
			})
		}

		t := c.Object(tpeName, func() graphql.ObjectConfig {
			fields := graphql.InputObjectConfigFieldMap{}

			for sf := range collection.IterStructField(context.Background(), rv) {
				field := &graphql.InputObjectFieldConfig{}
				field.Type = c.TypeOf(sf.Value, AsInput())
				if !sf.Optional {
					field.Type = graphql.NewNonNull(field.Type)
				}
				fields[sf.Name] = field
			}

			return graphql.ObjectConfig{
				Fields: fields,
			}
		})

		return graphql.NewScalar(graphql.ScalarConfig{
			Name: t.Name(),
		})
	case reflect.String:
		return graphql.String
	case reflect.Bool:
		return graphql.Boolean
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		return graphql.Int
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
		return graphql.Int
	case reflect.Float64, reflect.Float32:
		return graphql.Float
	case reflect.Interface:
		return c.Scalar("Any", graphql.ScalarConfig{
			Name: "Any",
			ParseLiteral: func(valueAST ast.Value) interface{} {
				return ToGoValue(valueAST)
			},
			ParseValue: func(value interface{}) interface{} {
				return value
			},
			Serialize: func(value interface{}) interface{} {
				return value
			},
		})
	}
	return nil
}

func (c *schemaConfigCollector) UnmarshalDirective(name string, args []*ast.Argument) (Directive, error) {
	d, ok := c.directives[name]
	if !ok {
		return nil, errors.Errorf("unsupported directive %s", name)
	}

	v := reflect.New(reflect.TypeOf(d).Elem()).Interface().(Directive)

	b := bytes.NewBufferString("{")
	for i, a := range args {
		if i > 0 {
			b.WriteString(",")
		}

		b.WriteString(strconv.Quote(a.Name.Value))
		b.WriteString(":")
		data, _ := json.Marshal(a.Value.GetValue())
		b.Write(data)
	}

	b.WriteString("}")

	if err := json.Unmarshal(b.Bytes(), v); err != nil {
		return nil, err
	}

	return v, nil
}

func (c *schemaConfigCollector) Scalar(name string, config graphql.ScalarConfig) graphql.Type {
	if t, ok := c.types[name]; ok {
		return t.Type()
	}

	config.Name = name

	c.types[name] = &typed{
		typ: graphql.NewScalar(config),
	}

	return c.types[name].Type()
}

func (c *schemaConfigCollector) InputObject(name string, getConfig func() graphql.InputObjectConfig) graphql.Type {
	if t, ok := c.types[name]; ok {
		return t.Type()
	}

	config := getConfig()
	config.Name = name

	c.types[name] = &typed{
		typ: graphql.NewInputObject(config),
	}

	return c.types[name].Type()
}

func (c *schemaConfigCollector) Object(name string, getConfig func() graphql.ObjectConfig) graphql.Type {
	if t, ok := c.types[name]; ok {
		return t.Type()
	}

	config := getConfig()
	config.Name = name

	c.types[name] = &typed{
		typ: graphql.NewObject(config),
	}

	return c.types[name].Type()
}

type typed struct {
	typ graphql.Type
}

func (t typed) Type() graphql.Type {
	return t.typ
}
