package main

import (
	"context"
	"github.com/innoai-tech/infra/pkg/cli"
	"github.com/innoai-tech/worklist/pkg/distribution"
)

func init() {
	cli.AddTo(App, &Publish{})
}

type Publish struct {
	cli.C
	Publisher
}

type Publisher struct {
	Context string `arg:""`

	ContainerRegistry distribution.ContainerRegistry `flag:",omitempty"`
}

func (p *Publisher) Run(ctx context.Context) error {
	c, err := distribution.Load(ctx, p.Context)
	if err != nil {
		return err
	}
	return distribution.Push(ctx, c, &p.ContainerRegistry)
}
