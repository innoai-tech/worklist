package gql

import (
	"bufio"
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
		p.PrintType(b, 0, d, true)
	}

	return b.Bytes(), nil

}

type printer struct {
}

func (p *printer) Fprint(w io.Writer, level int, text string) {
	if !strings.HasSuffix(text, "\n") {
		if level > 0 {
			_, _ = fmt.Fprint(w, strings.Repeat("  ", level))
		}
		_, _ = fmt.Fprint(w, text)
		return
	}

	// multi lines print
	scanner := bufio.NewScanner(bytes.NewBufferString(text))
	for scanner.Scan() {
		if text = scanner.Text(); text != "" {
			if level > 0 {
				_, _ = fmt.Fprint(w, strings.Repeat("  ", level))
			}
			_, _ = fmt.Fprintln(w, scanner.Text())
		} else {
			_, _ = fmt.Fprintln(w)
		}
	}
}

func (p *printer) PrintDescription(w io.Writer, lvl int, desc string) {
	if desc != "" {
		p.Fprint(w, lvl, fmt.Sprintf(`"""
%s
"""
`, desc))
	}
}

func (p *printer) PrintDirective(w io.Writer, directive *graphql.Directive) {
	p.PrintDescription(w, 0, directive.Description)

	p.Fprint(w, 0, fmt.Sprintf(`directive @%s(
`, directive.Name))

	for i, arg := range directive.Args {
		if i > 0 {
			p.Fprint(w, 1, "\n")
		}

		p.PrintDescription(w, 1, arg.Description())
		p.Fprint(w, 1, fmt.Sprintf("%s: ", arg.Name()))
		p.PrintType(w, 0, arg.Type, false)
		p.Fprint(w, 0, "\n")
	}

	p.Fprint(w, 0, fmt.Sprintf(") on %s", strings.Join(directive.Locations, ",")))
	p.Fprint(w, 0, "\n\n")
}

func (p *printer) PrintType(w io.Writer, lvl int, tpe graphql.Type, decl bool) {
	if decl {
		defer func() {
			p.Fprint(w, lvl, "\n\n")
		}()
	}

	switch x := tpe.(type) {
	case *graphql.InputObject:
		if decl {
			p.PrintDescription(w, 0, x.Description())
			p.Fprint(w, 0, fmt.Sprintf(`input %s {
`, x.Name()))
			for _, v := range x.Fields() {
				p.PrintDescription(w, 1, v.Description())
				p.Fprint(w, 1, fmt.Sprintf("%s: ", v.Name()))
				p.PrintType(w, 0, v.Type, false)
				p.Fprint(w, 0, "\n")
			}
			p.Fprint(w, 0, "}")
			return
		}
		p.Fprint(w, 0, x.Name())
	case *graphql.Object:
		if decl {
			p.PrintDescription(w, 0, x.Description())
			p.Fprint(w, 0, fmt.Sprintf(`type %s {
`, x.Name()))
			for _, v := range x.Fields() {
				p.PrintDescription(w, 1, v.Description)
				p.Fprint(w, 1, fmt.Sprintf("%s: ", v.Name))
				p.PrintType(w, 0, v.Type, false)
				p.Fprint(w, 0, "\n")
			}
			p.Fprint(w, 0, "}")
			return
		}
		p.Fprint(w, 0, x.Name())
	case *graphql.Scalar:
		if decl {
			p.PrintDescription(w, 0, x.Description())
			p.Fprint(w, lvl, fmt.Sprintf("scalar %s", x.Name()))
			return
		}
		p.Fprint(w, lvl, x.Name())
	case *graphql.Union:
		if decl {
			p.PrintDescription(w, 0, x.Description())
			p.Fprint(w, 0, fmt.Sprintf("union %s = ", x.Name()))
			for i, t := range x.Types() {
				if i > 0 {
					p.Fprint(w, 0, " | ")
				}
				p.PrintType(w, 0, t, false)
			}
			return
		}
		p.Fprint(w, 0, x.Name())
	case *graphql.Enum:
		if decl {
			p.PrintDescription(w, 0, x.Description())
			p.Fprint(w, 0, fmt.Sprintf(`enum %s {
`, x.Name()))
			for i, v := range x.Values() {
				if i > 0 {
					p.Fprint(w, 0, "\n")
				}

				p.PrintDescription(w, 1, v.Description)
				p.Fprint(w, 1, fmt.Sprintf(`%s
`, v.Name))
			}
			p.Fprint(w, 0, "}")
			return
		}
		p.Fprint(w, 0, x.Name())
	case *graphql.List:
		p.Fprint(w, 0, "[")
		p.PrintType(w, 0, x.OfType, decl)
		p.Fprint(w, 0, "]")
	case *graphql.NonNull:
		p.PrintType(w, lvl, x.OfType, decl)
		p.Fprint(w, 0, "!")
	}
}
