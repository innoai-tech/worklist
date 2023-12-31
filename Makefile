BUN = bun
BUNX = bunx --bun
WAGON = wagon -p wagon.cue

DEBUG = 0
ifeq ($(DEBUG),1)
	WAGON := $(WAGON) --log-level=debug
endif

dep:
	$(BUN) install

dep.update:
	$(BUNX) npm-check-updates --root -ws -ui

gen:
	$(BUNX) turbo run gen

gen.go:
	go run ./internal/cmd/tool gen ./cmd/worklist

fmt: fmt.go
	$(BUNX) turbo run fmt --force

fmt.go:
	goimports -w -l ./pkg

fmt.ts:
	$(BUNX) @biomejs/biome format --write .

test:
	$(BUNX) turbo run test --force

clean:
	find . -name '.turbo' -type d -prune -print -exec rm -rf '{}' \;
	find . -name '.dart_tool' -type d -prune -print -exec rm -rf '{}' \;
	find . -name 'build' -type d -prune -print -exec rm -rf '{}' \;
	find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;

include hack/buildinfo.mk
include hack/dotenv.mk
include hack/secret.mk

build.android:
	cd app/worklist && flutter build apk --release --build-number=$(BUILD_NUMBER) --target-platform android-arm64 --split-per-abi

INSTALL_DEVICE = $(shell adb devices | grep adb | awk '{ print $$1 }')

install.android:
	adb -s $(INSTALL_DEVICE) install app/worklist/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

archive:
	$(WAGON) do --output=.wagon/build go archive

pub.app:
	$(DISTRIBUTION) publish \
		--container-registry-endpoint=${CONTAINER_REGISTRY} \
		--container-registry-username=${CONTAINER_REGISTRY_USERNAME} \
		--container-registry-password=${CONTAINER_REGISTRY_PASSWORD} \
		./app/worklist

WORKLIST = go run ./cmd/worklist
DISTRIBUTION = go run ./cmd/distribution


install.worklist:
	go install ./cmd/worklist

debug.build.push:
	$(WORKLIST) build \
		--tag=${CONTAINER_REGISTRY}/worklist/example \
		--container-registry-username=${CONTAINER_REGISTRY_USERNAME} \
		--container-registry-password=${CONTAINER_REGISTRY_PASSWORD} \
		--push \
		./testdata/example

debug.export:
	$(WORKLIST) export \
		--tag=${CONTAINER_REGISTRY}/worklist/example \
		--output=./build/worklist.tar \
		./testdata/example

