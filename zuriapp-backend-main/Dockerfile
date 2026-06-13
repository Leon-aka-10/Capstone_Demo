# ── Stage 1: Install production deps ─────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Install ONLY production dependencies (no devDependencies in the image)
RUN npm ci --only=production

# ── Stage 2: Runtime ─────────────────────────────────────────────────────────
FROM node:20-alpine AS runtime

# Security: non-root user
RUN addgroup -S zurigroup && adduser -S zuriuser -G zurigroup

WORKDIR /app

# Copy production node_modules from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy application source
# server.js is the entry point
# data/ contains products.js
COPY server.js .
COPY data/ ./data/

# If there are other top-level files (.env.example etc.) you want excluded,
# add them to a .dockerignore file in the backend repo root:
#   node_modules
#   .env
#   .env.*
#   *.md

USER zuriuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:5000/health || exit 1

CMD ["node", "server.js"]