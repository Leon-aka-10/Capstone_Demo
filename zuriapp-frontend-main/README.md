# Zuri Market — Frontend

> React storefront for Zuri Market — African artisan products delivered across Europe.

---

## Tech Stack

| Layer       | Technology              |
|-------------|--------------------------|
| Framework   | React 18 / Next.js       |
| Styling     | Tailwind CSS / CSS Modules|
| HTTP Client | Axios                    |
| Container   | Docker + Nginx           |
| CI/CD       | GitHub Actions           |

---

## Local Setup

### Prerequisites
- Node.js 20+
- npm 9+

### 1. Clone the repo
```bash
git clone https://github.com/Test-class2026/zuriapp-frontend.git
cd zuriapp-frontend
```

### 2. Install dependencies
```bash
npm install
```

### 3. Configure environment variables
```bash
cp .env.example .env
```

Set `REACT_APP_API_URL` to your backend URL (e.g. `http://localhost:5000`).

### 4. Start the development server
```bash
npm start
```

App runs at `http://localhost:3000`.

---

## Environment Variables

| Variable              | Description                     | Required |
|-----------------------|---------------------------------|----------|
| `REACT_APP_API_URL`   | Backend API base URL            | Yes      |

---

## Docker

### Build the image
```bash
docker build -t zurimarket-frontend .
```

### Run the container
```bash
docker run -p 3000:80 zurimarket-frontend
```

---

## Testing
```bash
npm test
npm audit
```

---

## Deployment Overview

1. Push to `main` branch.
2. GitHub Actions builds and pushes the Docker image to DockerHub.
3. Kubernetes pulls the new image and performs a zero-downtime rolling update.
4. Traffic is routed through the k3s Traefik ingress controller.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| API calls failing | Check `REACT_APP_API_URL` in `.env` |
| Blank page after build | Check browser console for JS errors |
| Nginx 404 on page refresh | Ensure `nginx.conf` has the SPA fallback rule |
| Docker build fails | Ensure `npm run build` succeeds locally first |
