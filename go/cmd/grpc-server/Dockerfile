FROM gcr.io/cloud-builders/go:1.15 as builder
COPY . /tmp/build
WORKDIR /tmp/build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=mod -o . ./cmd/grpc-server

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /tmp/build/grpc-server .
ENTRYPOINT ["./grpc-server"]
LABEL Name=grpc-server Version=0.0.1
