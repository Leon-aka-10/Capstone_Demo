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

##############################################################################
# KUBECONFIG_DATA
#
# Terraform cannot SSH into the VM itself, so this output gives you the
# exact command to run immediately after `terraform apply` finishes.
#
# Step 1 — Wait ~3 minutes for cloud-init (k3s install) to complete
# Step 2 — Run the command below in your terminal
# Step 3 — Copy the output and add it as KUBECONFIG_DATA in GitHub Secrets
##############################################################################
output "kubeconfig_data_command" {
  value       = "ssh -o StrictHostKeyChecking=no ${var.admin_username}@${azurerm_public_ip.main.ip_address} \"base64 -w0 ~/.kube/config\""
  description = "Run this command after cloud-init finishes to get the KUBECONFIG_DATA value for GitHub Secrets."
}

output "kubeconfig_data_instructions" {
  value = <<-INSTRUCTIONS
    ──────────────────────────────────────────────────────
    KUBECONFIG_DATA — How to get it:

    1. Wait ~3 minutes after terraform apply (cloud-init runs k3s setup)

    2. Run this command in your terminal:
       ssh -o StrictHostKeyChecking=no ${var.admin_username}@${azurerm_public_ip.main.ip_address} "base64 -w0 ~/.kube/config"

    3. Copy the entire base64 output

    4. Go to GitHub → Settings → Secrets → New secret
       Name:  KUBECONFIG_DATA
       Value: <paste the base64 output>

    To verify k3s is ready before fetching:
       ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address} "kubectl get nodes"
    ──────────────────────────────────────────────────────
  INSTRUCTIONS
  description = "Step-by-step instructions to retrieve and store KUBECONFIG_DATA."
}
