##############################################################################
# keyvault.tf
# Azure Key Vault — the single source of truth for all application secrets.
# Nothing sensitive lives in code, .env files, or Slack.
#
# Resources:
#   - Key Vault instance
#   - Access policy for the Terraform service principal (manage secrets)
#   - Access policy for the VM managed identity (read secrets at runtime)
#   - User-assigned managed identity (used by k3s pods via CSI driver)
#   - Three secrets: Stripe key, Database URL, JWT secret
##############################################################################

# ── Key Vault ─────────────────────────────────────────────────────────────────
resource "azurerm_key_vault" "main" {
  name                       = "zurimarket-kv-${random_string.suffix.result}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false   # Set true only for production with compliance needs
  tags                       = azurerm_resource_group.main.tags
}

# ── Access policy: Terraform service principal (CI/CD writes secrets) ─────────
resource "azurerm_key_vault_access_policy" "terraform_sp" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]
}

# ── Managed Identity (used by Kubernetes pods to read from Key Vault) ─────────
resource "azurerm_user_assigned_identity" "k3s" {
  name                = "zurimarket-k3s-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = azurerm_resource_group.main.tags
}

# ── Access policy: Managed identity (pods read secrets at runtime) ────────────
resource "azurerm_key_vault_access_policy" "k3s_identity" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.k3s.principal_id

  secret_permissions = ["Get", "List"]
}

# ── Secrets ───────────────────────────────────────────────────────────────────
# Values are passed in by GitHub Actions as -var flags.
# They are NEVER hardcoded here or committed to Git.

resource "azurerm_key_vault_secret" "stripe_secret_key" {
  name         = "STRIPE-SECRET-KEY"
  value        = var.stripe_secret_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}

resource "azurerm_key_vault_secret" "database_url" {
  name         = "DATABASE-URL"
  value        = var.database_url
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}

resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "JWT-SECRET"
  value        = var.jwt_secret
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}
