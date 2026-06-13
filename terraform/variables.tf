##############################################################################
# variables.tf
# All input variables for the Zuri Market infrastructure.
# Override defaults in terraform.tfvars or via -var flags in the pipeline.
##############################################################################

variable "location" {
  type        = string
  default     = "uksouth"
  description = "Azure region. UK South is closest to Zuri Market HQ (London)."
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
