# ── Stage 1: Build (Vite) ────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Vite reads VITE_* env vars at build time via --build-arg
# Usage in code: import.meta.env.VITE_API_URL
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Vite outputs to /app/dist
RUN npm run build

# ── Stage 2: Serve with Nginx ────────────────────────────────────────────────
FROM nginx:1.25-alpine AS runtime

RUN rm -rf /usr/share/nginx/html/*

# Vite dist → nginx web root
COPY --from=builder /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:80 || exit 1

CMD ["nginx", "-g", "daemon off;"]
