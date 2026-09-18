# ---------- build stage ----------
# Contains the full Go toolchain; discarded after build.
FROM golang:1.26.6-alpine AS build
WORKDIR /app

COPY go.mod ./

# No external deps yet, but keep the happy path for when we add some
RUN go mod download

COPY . .

# Static binary, stripped: no cgo, trimmed path info,
# no debug/symbol tables. Minimal attack surface.
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o gopherbox .

# ---------- runtime stage ----------
# Only the compiled binary + rootfs. No shell, no package manager.
FROM gcr.io/distroless/static:nonroot
WORKDIR /

COPY --from=build /app/gopherbox /gopherbox

EXPOSE 8080
USER 65532:65532

ENTRYPOINT ["/gopherbox"]