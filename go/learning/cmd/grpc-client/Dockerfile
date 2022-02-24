FROM gcr.io/cloud-builders/go:1.15 as builder
COPY . /tmp/build
WORKDIR /tmp/build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=mod -o . ./cmd/grpc-client

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /tmp/build/grpc-client .
ENTRYPOINT ["./grpc-client"]
LABEL Name=grpc-client Version=0.0.1
