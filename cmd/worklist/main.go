package main

import (
	"context"
	"github.com/innoai-tech/worklist/internal/version"
	"os"

	"github.com/innoai-tech/infra/pkg/cli"
)

var App = cli.NewApp("worklist", version.Version())

func main() {
	if err := cli.Execute(context.Background(), App, os.Args[1:]); err != nil {
		os.Exit(1)
	}
}
