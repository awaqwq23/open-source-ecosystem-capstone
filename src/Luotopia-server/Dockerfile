FROM golang:1.26.2-alpine AS build

WORKDIR /src

COPY go.mod go.sum ./
ENV GOPROXY=https://goproxy.cn,direct
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/luotopia-server ./cmd/server
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/luotopia-migrate ./cmd/migrate

FROM alpine:3.22

RUN sed -i 's|dl-cdn.alpinelinux.org|mirrors.aliyun.com|g' /etc/apk/repositories && \
    apk add --no-cache ca-certificates tzdata

WORKDIR /app
RUN mkdir -p /app/configs

COPY --from=build /out/luotopia-server /app/luotopia-server
COPY --from=build /out/luotopia-migrate /app/luotopia-migrate
COPY internal/database/migrations /app/internal/database/migrations

EXPOSE 8080

CMD ["/app/luotopia-server"]
