# for Docker >= 17.5, it uses multistage build
FROM golang:1.10 as builder
WORKDIR /go/src/github.com/matihost/learning/go
COPY . .
WORKDIR cmd/language
RUN CGO_ENABLED=0 GOOS=linux go install -a -installsuffix cgo

FROM alpine:latest
COPY --from=builder /go/bin/language .
ENTRYPOINT ./language
LABEL Name=language Version=0.0.1
# EXPOSE 3000