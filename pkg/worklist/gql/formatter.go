package gql

import (
	"bytes"
	"fmt"
	"io"
	"strings"

	"github.com/graphql-go/graphql"
)

func Format(sc graphql.SchemaConfig) ([]byte, error) {
	b := bytes.NewBuffer(nil)

	p := &printer{}

	for _, d := range sc.Directives {
		p.PrintDirective(b, d)
	}

	for _, d := range sc.Types {
		p.PrintType(b, d, true)
	}

	return b.Bytes(), nil

}

type printer struct {
}

func (p *printer) PrintDirective(w io.Writer, directive *graphql.Directive) {
	_, _ = fmt.Fprintf(w, "directive @%s(", directive.Name)

	for i, arg := range directive.Args {
		if i > 0 {
			_, _ = fmt.Fprint(w, ", ")
		}

		_, _ = fmt.Fprintf(w, "%s: ", arg.Name())

		p.PrintType(w, arg.Type, false)
	}

	_, _ = fmt.Fprintf(w, ") on %s", strings.Join(directive.Locations, ","))
	_, _ = fmt.Fprint(w, "\n\n")
}

func (p *printer) PrintType(w io.Writer, tpe graphql.Type, decl bool) {
	if decl {
		defer func() {
			_, _ = fmt.Fprint(w, "\n\n")
		}()
	}

	switch x := tpe.(type) {
	case *graphql.InputObject:
		if decl {
			_, _ = fmt.Fprintf(w, "input %s {\n", x.Name())
			for _, v := range x.Fields() {
				_, _ = fmt.Fprintf(w, "  %s: ", v.Name())
				p.PrintType(w, v.Type, false)
				_, _ = fmt.Fprint(w, "\n")
			}
			_, _ = fmt.Fprint(w, "}")
			return
		}
		_, _ = fmt.Fprint(w, x.Name())
	case *graphql.Object:
		if decl {
			_, _ = fmt.Fprintf(w, "type %s {\n", x.Name())
			for _, v := range x.Fields() {
				_, _ = fmt.Fprintf(w, "  %s: ", v.Name)
				p.PrintType(w, v.Type, false)
				_, _ = fmt.Fprint(w, "\n")
			}
			_, _ = fmt.Fprint(w, "}")
			return
		}
		_, _ = fmt.Fprint(w, x.Name())
	case *graphql.Scalar:
		if decl {
			_, _ = fmt.Fprintf(w, "scalar %s", x.Name())
			return
		}
		_, _ = fmt.Fprint(w, x.Name())
	case *graphql.Union:
		if decl {
			_, _ = fmt.Fprintf(w, "union %s = ", x.Name())
			for i, t := range x.Types() {
				if i > 0 {
					_, _ = fmt.Fprint(w, " | ")
				}
				p.PrintType(w, t, false)
			}
			return
		}
		_, _ = fmt.Fprint(w, x.Name())
	case *graphql.Enum:
		if decl {
			_, _ = fmt.Fprintf(w, "enum %s {\n", x.Name())
			for _, v := range x.Values() {
				_, _ = fmt.Fprintf(w, "  %s\n", v.Name)
			}
			_, _ = fmt.Fprint(w, "}")
			return
		}
		_, _ = fmt.Fprint(w, x.Name())
	case *graphql.List:
		_, _ = fmt.Fprintf(w, "[")
		p.PrintType(w, x.OfType, decl)
		_, _ = fmt.Fprintf(w, "]")
	case *graphql.NonNull:
		p.PrintType(w, x.OfType, decl)
		_, _ = fmt.Fprintf(w, "!")
	}
}
