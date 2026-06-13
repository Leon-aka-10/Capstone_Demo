# Zuri Market — Backend API

> Node.js REST API powering the Zuri Market e-commerce platform.

---

## Tech Stack

| Layer       | Technology                      |
|-------------|----------------------------------|
| Runtime     | Node.js 20 (LTS)                |
| Framework   | Express.js                      |
| Database    | MongoDB / PostgreSQL             |
| Auth        | JWT                             |
| Payments    | Stripe                          |
| Container   | Docker (multi-stage build)       |
| Secrets     | Azure Key Vault (via CSI Driver) |

---

## Local Setup

### Prerequisites
- Node.js 20+
- npm 9+
- Docker (optional for local container run)

### 1. Clone the repo
```bash
git clone https://github.com/Test-class2026/zuriapp-backend.git
cd zuriapp-backend
```

### 2. Install dependencies
```bash
npm install
```

### 3. Configure environment variables

Copy the example file and fill in your local values:
```bash
cp .env.example .env
```

> **Never commit `.env` to Git.** It is already in `.gitignore`.

### 4. Start the development server
```bash
npm run dev
```

The API will be available at `http://localhost:5000`.

---

## Environment Variables

| Variable           | Description                        | Required |
|--------------------|------------------------------------|----------|
| `PORT`             | Port the server listens on         | Yes      |
| `NODE_ENV`         | `development` or `production`      | Yes      |
| `DATABASE_URL`     | MongoDB or PostgreSQL connection   | Yes      |
| `JWT_SECRET`       | Secret for signing JWT tokens      | Yes      |
| `STRIPE_SECRET_KEY`| Stripe API secret key              | Yes      |

In production these are injected from **Azure Key Vault** — they are never stored in the codebase or Slack.

---

## Docker

### Build the image
```bash
docker build -t zurimarket-backend .
```

### Run the container locally
```bash
docker run -p 5000:5000 \
  -e PORT=5000 \
  -e NODE_ENV=development \
  -e DATABASE_URL=your_db_url \
  -e JWT_SECRET=your_jwt_secret \
  -e STRIPE_SECRET_KEY=your_stripe_key \
  zurimarket-backend
```

---

## Testing
```bash
# Unit + integration tests
npm test

# Dependency vulnerability check
npm audit
```

---

## API Health Check

```
GET /health
→ 200 OK  {"status": "ok"}
```

---

## Deployment Overview

1. Push to `main` triggers the GitHub Actions pipeline.
2. Tests and security scans run automatically.
3. Docker image is built and pushed to DockerHub.
4. Terraform provisions/updates Azure infrastructure.
5. Kubernetes (k3s on Azure VM) pulls the image and performs a rolling update.
6. Secrets are mounted from Azure Key Vault via the CSI Secrets Store Driver.

See `.github/workflows/deploy.yml` for the full pipeline.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Cannot connect to database` | Check `DATABASE_URL` in your `.env` |
| `Invalid Stripe key` | Ensure `STRIPE_SECRET_KEY` starts with `sk_` |
| `JWT malformed` | Verify `JWT_SECRET` matches between services |
| Container exits immediately | Run `docker logs <container_id>` to inspect |
| k3s pod in `CrashLoopBackOff` | Run `kubectl logs -n zurimarket <pod>` |
