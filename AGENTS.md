# AGENTS.md

This document provides guidance for AI agents working on the container-tacplus project.

## Project Overview

**container-tacplus** is a containerized TACACS+ daemon that packages [tac_plus-ng](https://github.com/MarcJHuber/event-driven-servers) into a Docker container. TACACS+ is a network protocol for centralized authentication, authorization, and accounting (AAA) for network devices like routers and switches.

**Repository:** https://github.com/MattKobayashi/container-tacplus

## Tech Stack

- **Docker** - Container runtime and multi-stage builds
- **Debian trixie-slim** - Base container image
- **tac_plus-ng** - TACACS+ daemon from event-driven-servers project
- **GitHub Actions** - CI/CD pipelines
- **Renovate** - Automated dependency updates

## Directory Structure

```
container-tacplus/
├── .github/workflows/       # CI/CD workflows
│   ├── publish.yaml         # Release publishing to ghcr.io
│   └── test.yaml            # PR testing workflow
├── s6-rc.d/                 # s6-overlay service definitions (not currently used)
│   ├── init-tacplus/        # Config validation oneshot
│   └── svc-tacplus/         # Daemon long-running service
├── test/
│   ├── config/
│   │   └── tac_plus-ng.cfg  # Test configuration
│   └── docker-compose.yaml  # Test environment
├── Dockerfile               # Main container build
├── README.md                # User documentation
└── renovate.json            # Dependency update config
```

## Key Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Multi-stage build that compiles tac_plus-ng from source and creates runtime container |
| `README.md` | Usage documentation with Docker Compose examples |
| `.github/workflows/publish.yaml` | Publishes container to ghcr.io on release |
| `.github/workflows/test.yaml` | Tests container build and connectivity on PRs |
| `test/docker-compose.yaml` | Test environment with connection verification |
| `test/config/tac_plus-ng.cfg` | Example TACACS+ configuration for testing |

## Build Process

The Dockerfile uses a multi-stage build:

1. **Build stage**: Compiles tac_plus-ng from source using Debian with build dependencies
2. **Runtime stage**: Minimal image with only runtime dependencies

```bash
# Build the container
docker build -t tacplus .

# Run with custom config
docker run -p 49:49/tcp -v ./config.cfg:/opt/tac_plus-ng.cfg:ro tacplus
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TACPLUS_CFG_FILE` | Path to tac_plus-ng configuration file | `/opt/tac_plus-ng.cfg` |

## Testing

The test suite uses Docker Compose to:
1. Build the container from the Dockerfile
2. Run tac_plus-ng with a test configuration
3. Verify port 49 is accessible using netcat

```bash
# Run tests locally
docker compose -f test/docker-compose.yaml up --build --exit-code-from=connection_test
```

## CI/CD Workflows

### test.yaml
- **Triggers**: PRs to main, manual dispatch
- **Purpose**: Build container and verify connectivity
- **Runner**: ubuntu-24.04

### publish.yaml
- **Triggers**: Release published, manual dispatch
- **Purpose**: Build and publish to ghcr.io/mattkobayashi/tacplus
- **Uses**: Reusable workflow from MattKobayashi/actions-workflows

## Development Guidelines

1. **Dockerfile changes**: Test locally with `docker compose -f test/docker-compose.yaml up --build`
2. **Configuration changes**: Refer to [tac_plus-ng documentation](https://projects.pro-bono-publico.de/event-driven-servers/doc/tac_plus-ng.html)
3. **Version updates**: Renovate handles automated dependency updates with automerge

## Important Notes

- The container exposes port 49/tcp (standard TACACS+ port)
- Configuration files must be mounted as volumes
- The s6-rc.d directory contains service definitions prepared for s6-overlay but is not currently integrated into the main Dockerfile
- The upstream tac_plus-ng source is pinned to a specific commit in the Dockerfile
- If you are unsure how to do something, use `gh_grep` to search code examples from GitHub
- When you need to search docs, use `context7` tools

## External Resources

- [tac_plus-ng documentation](https://projects.pro-bono-publico.de/event-driven-servers/doc/tac_plus-ng.html)
- [event-driven-servers GitHub](https://github.com/MarcJHuber/event-driven-servers)
