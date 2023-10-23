package main

import (
	"context"
	"github.com/go-courier/logr"
	"github.com/go-courier/logr/slog"
	"github.com/innoai-tech/worklist/internal/version"
	"os"

	"github.com/innoai-tech/infra/pkg/cli"
)

var App = cli.NewApp("distribution", version.Version())

func main() {
	ctx := logr.WithLogger(context.Background(), slog.Logger(slog.Default()))

	if err := cli.Execute(ctx, App, os.Args[1:]); err != nil {
		os.Exit(1)
	}
}
