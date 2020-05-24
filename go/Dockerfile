FROM golang:1.13 as builder
COPY . /tmp/build
WORKDIR /tmp/build
RUN go build -o . ./cmd/language

FROM gcr.io/distroless/base
USER 1001
COPY --from=builder /tmp/build/language .
ENTRYPOINT ["./language"]
LABEL Name=language Version=0.0.1

# The GOPATH version of build, has to be first build step, executable in /go/bin/language
# FROM golang:1.13 as builder
# WORKDIR /go/src/github.com/matihost/learning/go
# COPY . .
# WORKDIR cmd/language
# RUN CGO_ENABLED=0 GOOS=linux go install -a -installsuffix cgo
