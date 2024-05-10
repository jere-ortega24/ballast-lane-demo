export CGO_ENABLED?=0

BINARY_NAME=demo-api

.PHONY: all
all: build

deps:
	go mod download

.PHONY: tidy
tidy:
	go mod tidy

fmt:
	go fmt ./...

lint:
	formated_files="$$(go fmt ./...)" && \
		echo "$${formated_files}" && \
		test -z "$${formated_files}"

.PHONY: prebuild
prebuild: deps fmt

.PHONY: build
build: prebuild
	GOARCH=amd64 GOOS=linux go build -ldflags -s -o ./build/${BINARY_NAME}

.PHONY: clean
clean:
	- go clean
	- rm -f ./build/

.PHONY: test
test: lint
