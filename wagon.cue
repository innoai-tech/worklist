import (
	"strings"
	"wagon.octohelm.tech/core"

	"github.com/innoai-tech/runtime/cuepkg/tool"
	"github.com/innoai-tech/runtime/cuepkg/golang"
	"github.com/innoai-tech/runtime/cuepkg/debian"
	"github.com/innoai-tech/runtime/cuepkg/imagetool"
)

pkg: version: core.#Version

client: core.#Client & {
	env: {
		GH_USERNAME: string | *""
		GH_PASSWORD: core.#Secret
	}
}

setting: core.#Setting & {
	registry: "ghcr.io": auth: {
		username: client.env.GH_USERNAME
		secret:   client.env.GH_PASSWORD
	}
}

actions: go: golang.#Project & {
	version: "\(pkg.version.output)"

	source: {
		path: "."
		include: [
			"cmd/",
			"pkg/",
			"internal/",
			"go.mod",
			"go.sum",
		]
	}
	goos: [
		"linux",
		"darwin",
	]
	goarch: [
		"amd64",
		"arm64",
	]
	main: "./cmd/worklist"
	ldflags: [
		"-s -w",
		"-X \(go.module)/internal/version.version=\(go.version)",
	]

	build: {
		pre: [
			"go mod download",
		]
	}
}
