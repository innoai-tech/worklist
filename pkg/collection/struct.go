package collection

import (
	"context"
	"reflect"
	"strings"
)

type StructField struct {
	Name     string
	Type     reflect.Type
	Value    reflect.Value
	Tag      reflect.StructTag
	Optional bool
}

func IterStructField(ctx context.Context, rv reflect.Value) <-chan StructField {
	ch := make(chan StructField)

	go func() {
		defer func() {
			close(ch)
		}()

		for rv.Kind() == reflect.Ptr {
			rv = rv.Elem()
		}

		tpe := rv.Type()

		if tpe.Kind() != reflect.Struct {
			return
		}

		for i := 0; i < tpe.NumField(); i++ {
			f := tpe.Field(i)

			if !f.IsExported() {
				continue
			}

			tag := f.Tag

			omitempty := false
			name, ok := tag.Lookup("json")
			if ok {
				if name == "-" {
					continue
				}
				omitempty = strings.Contains(name, ",omitempty")
				name = strings.SplitN(name, ",", 2)[0]
			} else {
				name = f.Name
			}

			fv := rv.Field(i)

			if f.Anonymous && f.Type.Kind() == reflect.Struct && !isNamerStruct(f) {
				for s := range IterStructField(ctx, fv) {
					select {
					case <-ctx.Done():
						return
					case ch <- s:
					}
				}
				continue
			}

			sf := StructField{
				Name:     name,
				Value:    fv,
				Type:     f.Type,
				Optional: omitempty,
				Tag:      tag,
			}

			select {
			case <-ctx.Done():
				return
			case ch <- sf:
			}
		}
	}()

	return ch
}

func isNamerStruct(sf reflect.StructField) bool {
	if sf.Name != "Name" {
		return false
	}
	pkgPath := sf.Type.PkgPath()
	if pkgPath == "" {
		return false
	}
	return true
}
