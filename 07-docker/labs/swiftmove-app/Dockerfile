# syntax=docker/dockerfile:1
# Production multi-stage Dockerfile for the SwiftMove app.
# Stage 1 (builder) installs dependencies. Stage 2 (runtime) ships only what runs.

# ---------- Stage 1: builder ----------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy ONLY the dependency manifests first (caching: code changes do not force a reinstall).
COPY package.json package-lock.json* ./

# Install production dependencies only.
RUN npm install --omit=dev

# Copy the rest of the source code.
COPY . .

# ---------- Stage 2: runtime ----------
FROM node:20-alpine AS runtime

WORKDIR /app

# Create a non-root user to run the app (least privilege inside the container).
RUN addgroup -S app && adduser -S -G app -u 10001 app

# Copy only what is needed to run, owned by the non-root user.
COPY --from=builder --chown=app:app /app/node_modules ./node_modules
COPY --from=builder --chown=app:app /app/package.json ./package.json
COPY --from=builder --chown=app:app /app/src ./src
COPY --chown=app:app healthcheck.js ./healthcheck.js

# Switch to the non-root user.
USER 10001

EXPOSE 3000

# Health check calls the standalone script in JSON (exec) form: no shell wrapper, cleaner.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["node", "healthcheck.js"]

CMD ["node", "src/server.js"]
