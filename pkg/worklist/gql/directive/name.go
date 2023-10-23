package directive

import (
	"github.com/graphql-go/graphql"
)

type Name struct {
	config *NameConfig
}

func (n Name) Directive() *graphql.Directive {
	return graphql.NewDirective(graphql.DirectiveConfig{
		Name:        n.config.Name,
		Description: n.config.Description,
		Locations:   n.config.On,
		Args:        n.config.Args,
	})
}

func (n *Name) SetConfig(nameConfig *NameConfig) {
	n.config = nameConfig
}

type NameConfig struct {
	Name        string
	Description string
	On          []string
	Args        map[string]*graphql.ArgumentConfig
}

type ConfigSetter interface {
	SetConfig(nameConfig *NameConfig)
}
