##############################################################################
# compute.tf
# Linux VM that runs the k3s single-node Kubernetes cluster.
# k3s, Helm, and the Azure Key Vault CSI driver are installed via cloud-init
# on first boot — no manual SSH required.
##############################################################################

resource "azurerm_linux_virtual_machine" "main" {
  name                = "zurimarket-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = azurerm_resource_group.main.tags

  network_interface_ids = [azurerm_network_interface.main.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # cloud-init runs on first boot automatically
  # Installs: k3s → Helm → Secrets Store CSI Driver → Azure Key Vault provider
  custom_data = base64encode(<<-CLOUDINIT
    #!/bin/bash
    set -e

    apt-get update -y
    apt-get install -y curl wget git

    # ── k3s (lightweight Kubernetes) ──────────────────────────────────────
    curl -sfL https://get.k3s.io | \
      INSTALL_K3S_EXEC="--tls-san ${azurerm_public_ip.main.ip_address}" sh -

    # Make kubeconfig accessible to the admin user
    mkdir -p /home/${var.admin_username}/.kube
    cp /etc/rancher/k3s/k3s.yaml /home/${var.admin_username}/.kube/config
    chown -R ${var.admin_username}:${var.admin_username} /home/${var.admin_username}/.kube

    # Replace 127.0.0.1 with the real public IP so remote kubectl works
    sed -i "s/127.0.0.1/${azurerm_public_ip.main.ip_address}/g" \
      /home/${var.admin_username}/.kube/config

    # ── Helm ──────────────────────────────────────────────────────────────
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # Wait for k3s to be fully ready before installing Helm charts
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    until kubectl get nodes | grep -q "Ready"; do sleep 5; done

    # ── Secrets Store CSI Driver ──────────────────────────────────────────
    helm repo add secrets-store-csi-driver \
      https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
    helm repo update

    helm install csi-secrets-store \
      secrets-store-csi-driver/secrets-store-csi-driver \
      --namespace kube-system \
      --set syncSecret.enabled=true \
      --set enableSecretRotation=true

    # ── Azure Key Vault provider for CSI Driver ───────────────────────────
    helm repo add csi-secrets-store-provider-azure \
      https://azure.github.io/secrets-store-csi-driver-provider-azure/charts

    helm install azure-csi-provider \
      csi-secrets-store-provider-azure/csi-secrets-store-provider-azure \
      --namespace kube-system

    echo "✅ cloud-init complete"
  CLOUDINIT
  )
}
