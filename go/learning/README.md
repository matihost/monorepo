# Go

[![Go Report Card](https://goreportcard.com/badge/github.com/matihost/monorepo/go/learning)](https://goreportcard.com/report/github.com/matihost/monorepo/go/learning)

Various Go applications showing Go lang structure, concepts, sample libraries usage (gRPC server/client, HTTP server), build, dependency management etc.

Project files structure follows [project-layout](https://github.com/golang-standards/project-layout) recommendation.

Project is build as Go module.

However it supports GOPATH style of building as well though [Dep](https://golang.github.io/dep/) (dependency management tool for Go).

## Prerequisites

Go lang 1.24.x+

## Installing

```bash
APPS="language http-server"
for i in $APPS; do
  go install "github.com/matihost/monorepo/go/learning/cmd/${i}@latest"
done
```

## Building from code

```bash

# will make symbolic lint in current GOPATH  so that the source code can be cloned into whatever localization on disk
# Compiled application will land is root source code directory
make build

# to remove vendor directory adn compiled application
make clean

# run go tests
make test

# to build application packaged as Docker
make build-image

# to run application Docker container from previously created Docker image
make run-container
```
