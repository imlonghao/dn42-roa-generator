FROM golang:1.13-alpine AS builder
LABEL maintainer="imlonghao <dockerfile@esd.cc>"
WORKDIR /builder
COPY main.go /builder
RUN apk add upx && \
    go build -ldflags="-s -w" -o /app && \
    upx --lzma --best /app

FROM alpine:latest
RUN apk --no-cache add ca-certificates git
COPY --from=builder /app /
COPY entrypoint.sh /
CMD ["/entrypoint.sh"]