# gopherbox

A minimal Go web server, containerized with Docker. Built as **Project 1** of the [DevOps & Systems Architecture roadmap](../../../ROADMAP.md) — learning the full container lifecycle from a Dockerfile and the terminal.

## What it does

- HTTP server on `:8080` returning `gopherbox says: hello from <ENV_NAME>`
- Reads `ENV_NAME` from the environment (defaults to `unknown`)
- Graceful shutdown on `SIGTERM`/`SIGINT`
- Runs as **non-root** (UID 65532) inside the container

## Run it

```bash
docker build -t gopherbox:v1 .
docker run -d -p 8080:8080 --name app-instance -e ENV_NAME=local gopherbox:v1
docker logs -f app-instance
curl http://localhost:8080   # -> gopherbox says: hello from local
```

Clean up:

```bash
docker kill app-instance && docker rm app-instance
```

## Image size

Multi-stage build with a `golang:alpine` build stage and a `gcr.io/distroless/static:nonroot` runtime stage: **14.3MB** (vs ~480MB single-stage).

| Stage | Base image | Contents |
|---|---|---|
| build | `golang:1.26.6-alpine` | Go toolchain, source, `go build` |
| runtime | `distroless/static:nonroot` | Static binary only — no shell, no package manager, non-root |

## Why multi-stage

The final image carries only the compiled static binary (`CGO_ENABLED=0`, `-ldflags="-s -w"`), shrinking attack surface and pull size. Skills transferred: layer caching, build contexts, `USER` hardening, and image hygiene — all core to deploying containers safely.

## Layout

```
main.go          HTTP server (8080), ENV_NAME, graceful shutdown
Dockerfile       multi-stage build -> distroless/static:nonroot
.dockerignore    keeps local artifacts & docs out of the build context
go.mod           module github.com/elucifurr/gopherbox
```