#!/bin/bash
# Install Tailscale; join the tailnet only when an auth key is provided.
curl -fsSL https://tailscale.com/install.sh | sh
if [ -n "${tailscale_auth_key}" ]; then
  tailscale up --authkey="${tailscale_auth_key}" --hostname="${hostname}"
fi
