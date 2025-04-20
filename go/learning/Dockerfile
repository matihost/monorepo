FROM golang:1.24 AS builder
COPY . /tmp/build
WORKDIR /tmp/build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=mod -o . ./cmd/language

FROM gcr.io/distroless/static:debug-nonroot
COPY --from=builder /tmp/build/language .
ENTRYPOINT ["./language"]
LABEL Name=language Version=0.0.1

# The GOPATH version of build, has to be first build step, executable in /go/bin/language
# FROM golang:1.24 AS builder
# WORKDIR /go/src/github.com/matihost/monorepo/go/learning
# COPY . .
# WORKDIR cmd/language
# RUN CGO_ENABLED=0 GOOS=linux go install -a -installsuffix cgo
