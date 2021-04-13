FROM gcr.io/cloud-builders/go:1.15 as builder
COPY . /tmp/build
WORKDIR /tmp/build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=mod -o . ./cmd/grpc-server
RUN wget -O /tmp/build/grpc-health-probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.3.6/grpc_health_probe-linux-amd64 && \
    chmod +x /tmp/build/grpc-health-probe

FROM gcr.io/distroless/static:debug-nonroot
COPY --from=builder /tmp/build/grpc-server .
COPY --from=builder /tmp/build/grpc-health-probe .
ENTRYPOINT ["./grpc-server"]
LABEL Name=grpc-server Version=0.0.1
