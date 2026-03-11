# =============================================================================
# Production Dockerfile: Python / FastAPI with uv
# Multi-stage build optimized for layer caching and minimal image size
#
# Build:  docker build -t crm-api:latest .
# Run:    docker run -p 8000:8000 --env-file .env crm-api:latest
# =============================================================================

# ---------------------------------------------------------------------------
# Stage 1: Builder
# Install dependencies into a virtual environment using uv.
# This stage has build tools; they won't be in the final image.
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS builder

# Install uv — fast Python package manager (replaces pip)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Copy dependency files FIRST — this layer is cached until pyproject.toml
# or uv.lock change, so code changes don't re-install all dependencies
COPY pyproject.toml uv.lock ./

# Install dependencies (cached via BuildKit mount)
# --frozen: fail if lockfile is out of date (reproducible builds)
# --no-dev: skip dev dependencies (pytest, etc.)
# --no-editable: don't install project in editable mode
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-editable

# Copy application source code
COPY api/ ./api/
COPY agent/ ./agent/
COPY database/ ./database/

# Install the project itself (registers entry points)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev


# ---------------------------------------------------------------------------
# Stage 2: Runtime
# Minimal image with only the app and its compiled dependencies.
# No build tools, no source caches, no dev dependencies.
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS runtime

# Create a non-root user for security
RUN groupadd -r app && useradd -r -g app -d /app -s /sbin/nologin app

WORKDIR /app

# Copy the virtual environment from builder (contains all installed packages)
COPY --from=builder /app/.venv /app/.venv

# Copy application source code
COPY --from=builder /app/api/ ./api/
COPY --from=builder /app/agent/ ./agent/
COPY --from=builder /app/database/ ./database/

# Add venv to PATH so Python finds installed packages
ENV PATH="/app/.venv/bin:$PATH"

# Python runtime settings
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Health check — baseline for standalone Docker and Compose
# K8s uses its own probes, but this ensures container-level monitoring
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Document the port (does not publish it — use -p or Compose ports:)
EXPOSE 8000

# Switch to non-root user
USER app

# Exec form ENTRYPOINT — process gets PID 1, receives SIGTERM for graceful shutdown
# CMD provides default arguments (overridable with docker run args)
ENTRYPOINT ["uvicorn", "api.main:app"]
CMD ["--host", "0.0.0.0", "--port", "8000"]
