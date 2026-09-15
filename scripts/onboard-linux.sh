#!/usr/bin/env bash
# Azure Arc onboarding script — Ubuntu 22.04 (arm64)
#
# Connects this machine to Azure Arc using a service principal.
# Idempotent: skips if already connected.
#
# Required environment variables (see .env):
#   AZURE_SUBSCRIPTION_ID
#   AZURE_RESOURCE_GROUP
#   AZURE_LOCATION
#   AZURE_TENANT_ID
#   AZURE_SP_CLIENT_ID
#   AZURE_SP_CLIENT_SECRET
#
# Usage:
#   source .env
#   sudo -E ./scripts/onboard-linux.sh
#
# Or pass values explicitly:
#   AZURE_SUBSCRIPTION_ID=... AZURE_RESOURCE_GROUP=... ./scripts/onboard-linux.sh

set -euo pipefail

# --- Required variables -----------------------------------------------------
: "${AZURE_SUBSCRIPTION_ID:?AZURE_SUBSCRIPTION_ID is required}"
: "${AZURE_RESOURCE_GROUP:?AZURE_RESOURCE_GROUP is required}"
: "${AZURE_LOCATION:?AZURE_LOCATION is required}"
: "${AZURE_TENANT_ID:?AZURE_TENANT_ID is required}"
: "${AZURE_SP_CLIENT_ID:?AZURE_SP_CLIENT_ID is required}"
: "${AZURE_SP_CLIENT_SECRET:?AZURE_SP_CLIENT_SECRET is required}"

AGENT_INSTALL_URL="https://aka.ms/azcmagent"
AGENT_INSTALL_SCRIPT="/tmp/install_linux_azcmagent.sh"

# --- 1. Install the Azure Connected Machine agent if missing ----------------
if ! command -v azcmagent >/dev/null 2>&1; then
  echo "==> Installing Azure Connected Machine agent..."
  curl -fsSL "${AGENT_INSTALL_URL}" -o "${AGENT_INSTALL_SCRIPT}"
  bash "${AGENT_INSTALL_SCRIPT}"
else
  echo "==> azcmagent already installed."
fi

# --- 2. Connect to Azure Arc (idempotent) ------------------------------------
CONNECTED=$(
  azcmagent show 2>/dev/null \
    | awk -F': ' '/^Agent Status|^Status/{print $2}' \
    | tr -d '[:space:]'
)

if [ "${CONNECTED}" = "Connected" ]; then
  echo "==> Already connected to Azure Arc. Skipping connect."
else
  echo "==> Connecting to Azure Arc..."
  azcmagent connect \
    --service-principal-id "${AZURE_SP_CLIENT_ID}" \
    --service-principal-secret "${AZURE_SP_CLIENT_SECRET}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --tenant-id "${AZURE_TENANT_ID}" \
    --location "${AZURE_LOCATION}" \
    --subscription-id "${AZURE_SUBSCRIPTION_ID}"
fi

# --- 3. Show final status ----------------------------------------------------
echo "==> Agent status:"
azcmagent show
