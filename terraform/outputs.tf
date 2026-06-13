##############################################################################
# outputs.tf
# Values printed after `terraform apply`.
# Use these to populate GitHub Secrets and Kubernetes manifests.
##############################################################################

output "vm_public_ip" {
  value       = azurerm_public_ip.main.ip_address
  description = "Public IP of the k3s VM. SSH: ssh zuriops@<ip>. Also add as VM_PUBLIC_IP GitHub Secret."
}

output "key_vault_name" {
  value       = azurerm_key_vault.main.name
  description = "Key Vault name — add as KEY_VAULT_NAME GitHub Secret."
}

output "key_vault_uri" {
  value       = azurerm_key_vault.main.vault_uri
  description = "Key Vault URI (https://<name>.vault.azure.net/)."
}

output "managed_identity_client_id" {
  value       = azurerm_user_assigned_identity.k3s.client_id
  description = "Client ID of the k3s managed identity — add as MANAGED_IDENTITY_CLIENT_ID GitHub Secret and in secret-provider-class.yaml."
}

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Resource group containing all Zuri Market infrastructure."
}
