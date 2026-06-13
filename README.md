# Zuri Market — DevOps Setup Guide
## Complete Step-by-Step Execution Order

---

## Prerequisites (install these first)

```bash
# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az --version

# Terraform
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip && sudo mv terraform /usr/local/bin/
terraform --version

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
```

---

## PHASE 1 — Azure Setup

### Step 1: Login and create service principal
```bash
az login

# Note your subscription ID from the output, then:
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

az ad sp create-for-rbac \
  --name "zurimarket-github-sp" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID \
  --sdk-auth
```
**Save the JSON output** — you'll need it for GitHub Secrets.

### Step 2: Bootstrap Terraform remote state
```bash
chmod +x terraform/bootstrap.sh
./terraform/bootstrap.sh
```

---

## PHASE 2 — Terraform (Provision Infrastructure)

```bash
cd terraform

# Set your SSH public key path in terraform.tfvars (or pass -var flag)
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

After apply, note these outputs:
```bash
terraform output vm_public_ip           # → Save as VM_IP
terraform output key_vault_name         # → Save as KEY_VAULT_NAME
terraform output managed_identity_client_id  # → Save as MANAGED_IDENTITY_CLIENT_ID
```

---

## PHASE 3 — k3s Kubeconfig

The VM already has k3s installed via cloud-init. Wait ~3 minutes after Terraform apply, then:

```bash
VM_IP=$(terraform output -raw vm_public_ip)

# Copy kubeconfig from VM
ssh zuriops@$VM_IP "cat ~/.kube/config" > /tmp/kubeconfig-zurimarket

# Encode it for GitHub Secrets
base64 -w 0 /tmp/kubeconfig-zurimarket
# → Copy this output as KUBECONFIG_DATA secret
```

---

## PHASE 4 — GitHub Secrets

In your GitHub repos (both frontend and backend), add these secrets:

| Secret Name                    | Where to get it                          |
|-------------------------------|------------------------------------------|
| `AZURE_CLIENT_ID`             | Service principal JSON → `clientId`      |
| `AZURE_CLIENT_SECRET`         | Service principal JSON → `clientSecret`  |
| `AZURE_SUBSCRIPTION_ID`       | Service principal JSON → `subscriptionId`|
| `AZURE_TENANT_ID`             | Service principal JSON → `tenantId`      |
| `DOCKERHUB_USERNAME`          | Your DockerHub username                  |
| `DOCKERHUB_TOKEN`             | DockerHub → Account Settings → Tokens    |
| `KUBECONFIG_DATA`             | base64 output from Phase 3              |
| `KEY_VAULT_NAME`              | `terraform output key_vault_name`        |
| `MANAGED_IDENTITY_CLIENT_ID`  | `terraform output managed_identity_client_id` |
| `STRIPE_SECRET_KEY`           | Stripe dashboard → API Keys             |
| `DATABASE_URL`                | Your MongoDB Atlas / PostgreSQL URL      |
| `JWT_SECRET`                  | Any strong random string (min 32 chars)  |

---

## PHASE 5 — First Deployment

```bash
# Push to main to trigger the pipeline
git add .
git commit -m "feat: initial deployment setup"
git push origin main
```

Monitor the pipeline at:
`https://github.com/Test-class2026/zuriapp-backend/actions`

---

## PHASE 6 — Verify

```bash
VM_IP=$(terraform -chdir=terraform output -raw vm_public_ip)

# Check pods are running
kubectl get pods -n zurimarket

# Access the app
curl http://$VM_IP
open http://$VM_IP   # in browser
```

---

## Cost Control (Student Account)

```bash
# Deallocate VM when not demoing (stops billing for compute)
az vm deallocate --resource-group zurimarket-rg --name zurimarket-vm

# Start it again before demo
az vm start --resource-group zurimarket-rg --name zurimarket-vm

# Nuke everything after the cohort ends
terraform destroy
```

---

## Demo Day Checklist

- [ ] Push a commit and show pipeline running in GitHub Actions
- [ ] Show green security scan results (Trivy, tfsec, gitleaks, npm audit)
- [ ] Show Docker image on DockerHub with the commit SHA tag
- [ ] Show Azure portal → Key Vault secrets (no values visible in code)
- [ ] Show Terraform resources in Azure portal under `zurimarket-rg`
- [ ] Open the app in browser via the VM public IP
- [ ] Run `kubectl get pods -n zurimarket` — show 2 replicas running
- [ ] Show `.env` is in `.gitignore` and no secrets in any file
