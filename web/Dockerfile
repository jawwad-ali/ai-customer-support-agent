# =============================================================================
# Production Dockerfile: Next.js with standalone output
# Three-stage build: dependencies -> build -> runtime
#
# PREREQUISITE: next.config.ts must include: output: 'standalone'
#
# Build:  docker build -t crm-web:latest --build-arg NEXT_PUBLIC_API_URL=http://api:8000 ./web
# Run:    docker run -p 3000:3000 crm-web:latest
# =============================================================================

# ---------------------------------------------------------------------------
# Stage 1: Dependencies
# Install node_modules. Cached until package.json or lockfile changes.
# ---------------------------------------------------------------------------
FROM node:22-alpine AS deps

WORKDIR /app

# Copy lockfile and package.json FIRST for layer caching
COPY package.json package-lock.json ./

# npm ci: clean install from lockfile (reproducible, no package-lock updates)
RUN npm ci --ignore-scripts


# ---------------------------------------------------------------------------
# Stage 2: Builder
# Build the Next.js application. Produces .next/ directory.
# ---------------------------------------------------------------------------
FROM node:22-alpine AS builder

WORKDIR /app

# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy all source files
COPY . .

# Build-time environment variables
# NEXT_PUBLIC_* vars are baked into the client bundle at build time
# Override via --build-arg when building for different environments
ARG NEXT_PUBLIC_API_URL=http://localhost:8000
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

# Build the Next.js application
# With output: 'standalone' in next.config, this produces a self-contained server
RUN npm run build


# ---------------------------------------------------------------------------
# Stage 3: Runner
# Minimal runtime — only the standalone server output and static assets.
# No node_modules, no source code, no build tools.
# ---------------------------------------------------------------------------
FROM node:22-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Create non-root user (alpine uses addgroup/adduser, not groupadd/useradd)
RUN addgroup -S app && adduser -S -G app -h /app app

# Copy standalone output (self-contained Node.js server)
COPY --from=builder /app/.next/standalone ./

# Copy static assets (not included in standalone output)
COPY --from=builder /app/.next/static ./.next/static

# Copy public directory (favicon, images, etc.)
COPY --from=builder /app/public ./public

# Health check for standalone Docker and Compose
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "const http = require('http'); const req = http.get('http://localhost:3000', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); }); req.on('error', () => process.exit(1));"

EXPOSE 3000

# Switch to non-root user
USER app

# Start the standalone Next.js server
CMD ["node", "server.js"]
