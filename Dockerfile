# Marmot built from source so the MCP handler can run behind the app
# platform's proxy. The proxy reaches Marmot over loopback with the public
# Host header, and go-sdk's DNS rebinding check rejects that with 403.
# Marmot 0.11.0 has no setting for DisableLocalhostProtection.
ARG MARMOT_VERSION=v0.11.0

FROM alpine/git:latest AS source
ARG MARMOT_VERSION
WORKDIR /src
RUN git clone --depth 1 --branch "$MARMOT_VERSION" https://github.com/marmotdata/marmot.git . \
    && sed -i 's/Stateless: true,/Stateless: true, DisableLocalhostProtection: true,/' \
        internal/api/v1/mcp/operations.go \
    && grep -q 'DisableLocalhostProtection: true' internal/api/v1/mcp/operations.go

FROM node:22-alpine AS frontend
RUN corepack enable && corepack prepare pnpm@11 --activate
WORKDIR /app/web/marmot
COPY --from=source /src/web/marmot/ ./
RUN pnpm install --frozen-lockfile \
    && node scripts/generate-icon-bundle.mjs \
    && pnpm build

FROM golang:1.26 AS builder
WORKDIR /app
COPY --from=source /src/ ./
COPY --from=frontend /app/web/marmot/build ./internal/staticfiles/build
RUN CGO_ENABLED=0 go build -tags production -ldflags '-s -w' -o marmot ./cmd/main.go

FROM alpine:3.23.3
RUN apk upgrade --no-cache && apk add --no-cache ca-certificates tzdata \
    && adduser -D -u 10001 marmot
COPY --from=builder /app/marmot /usr/local/bin/marmot
COPY entrypoint.sh /usr/local/bin/aiven-entrypoint.sh
RUN chmod 0755 /usr/local/bin/marmot /usr/local/bin/aiven-entrypoint.sh
WORKDIR /app
USER marmot

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/aiven-entrypoint.sh"]
CMD ["run"]
