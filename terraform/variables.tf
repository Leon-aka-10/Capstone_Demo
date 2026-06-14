##############################################################################
# variables.tf
# All input variables for the Zuri Market infrastructure.
# Override defaults in terraform.tfvars or via -var flags in the pipeline.
##############################################################################

variable "location" {
  type        = string
  default     = "francecentral"
  description = "Azure region. France Central used for student account AZ availability."
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment environment tag (production / staging / dev)."
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "VM SKU for the k3s host. B2s (2 vCPU / 4 GB) is student-account safe."
}

variable "admin_username" {
  type        = string
  default     = "zuriops"
  description = "Linux admin user created on the VM."
}

variable "ssh_public_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Path to your SSH public key. Used for VM access."
}

# ── Sensitive variables (injected by GitHub Actions, never hardcoded) ─────────

variable "stripe_secret_key" {
  type        = string
  sensitive   = true
  default     = "placeholder-set-via-pipeline"
  description = "Stripe API secret key — stored in Azure Key Vault."
}

variable "database_url" {
  type        = string
  sensitive   = true
  default     = "placeholder-set-via-pipeline"
  description = "MongoDB or PostgreSQL connection string — stored in Azure Key Vault."
}

variable "jwt_secret" {
  type        = string
  sensitive   = true
  default     = "placeholder-set-via-pipeline"
  description = "JWT signing secret — stored in Azure Key Vault."
}

# ── Azure auth variables (resolved from ARM_ env vars in CI) ──────────────────
# These don't need to be set manually — Terraform reads ARM_SUBSCRIPTION_ID
# and ARM_TENANT_ID from the environment automatically when ARM_USE_CLI=true.
# Listed here only for documentation purposes.

# ARM_SUBSCRIPTION_ID → set as GitHub Secret
# ARM_TENANT_ID       → set as GitHub Secret
# ARM_ACCESS_KEY      → set as GitHub Secret (storage account key for state)
