# Tech Stack

Technology stack for the Azure Arc Hybrid Governance Lab. Everything is chosen to keep the running cost at **$0/month**.

## Summary

| Category | Technology | Cost |
|---|---|---|
| Cloud platform | Azure Arc (control plane) | Free |
| Governance | Azure Policy (resource-level) | Free |
| Patch management | Azure Update Manager | Free |
| Observability | Azure Monitor / Log Analytics (DCR) | Free (5GB/mo) |
| IaC | Terraform + `azurerm` provider | Free |
| Config management | Ansible + `ansible-lockdown` | Free |
| Virtualization | Multipass VM (CLI, Apple Silicon) | Free |
| Guest OS | Ubuntu 22.04 LTS (arm64) | Free |
| Security audit | Lynis | Free |
| Presentation | Astro + Tailwind CSS (static) | Free |
| Hosting | Azure Static Web Apps (custom domain) + Cloudflare DNS | Free |
| Networking | Tailscale (mesh VPN) | Free |
| Cloud compute | Azure VM (B1ls) | ~$2/month |
| CI/CD | GitHub Actions (OIDC) | Free (public repo) |
| VCS | Git / GitHub | Free |

## Cloud Platform (Azure)

- **Azure Arc** — hybrid onboarding & control plane (inventory, RBAC, tagging)
  - Azure Connected Machine agent (`azcmagent`)
- **Azure Policy** — resource-level governance (3 policies: required tag / allowed regions / AMA extension)
- **Azure Update Manager** — patch assessment + scheduled patching
- **Azure Monitor / Log Analytics** — minimal log collection
  - Azure Monitor Agent (AMA)
  - Data Collection Rules (DCR) — scoped to stay under 5GB/month

> **Deliberately excluded (paid):** Machine Configuration (Guest Configuration, $6/server/month), Microsoft Defender for Servers, Microsoft Sentinel.

## Infrastructure as Code

- **Terraform** (`>= 1.5`)
- **`azurerm` provider** (HashiCorp)
- **Terraform modules** — `resource-group`, `policy`

## Configuration Management

- **Ansible** — VM bootstrap + CIS hardening (enforcement)
  - `ansible-lockdown` CIS roles — enforce CIS baselines (e.g., `UBUNTU22-CIS`)

## Virtualization & OS

- **Multipass** — Canonical CLI VM manager (Apple Silicon native, `multipass launch/exec/shell`)
- **Ubuntu 22.04 LTS (arm64)** — guest OS on 2 VMs

## Scripting & Automation

- **Bash** — lightweight glue + audit orchestration
- **Lynis** — open-source security auditing (detect; pairs with Ansible CIS roles to remediate)

## Presentation & Hosting

- **Astro** — static site framework (zero-JS by default, fast)
- **Tailwind CSS** — styling
- **Azure Static Web Apps** — static hosting + custom domain (`azure-arc-hybrid.techcloudup.com`), DNS via Cloudflare
- **CI snapshot pipeline** — scheduled GitHub Actions runs `az graph` / `az policy` queries (OIDC) → commits snapshot JSON → triggers build

## Networking

- **Tailscale** — WireGuard-based mesh VPN (free personal tier)
- **Azure VM** (B1ls) — cloud-side node for hybrid connectivity (~$2/month, deallocate when idle)

## CI/CD & Version Control

- **Git** / **GitHub** (public repo)
- **GitHub Actions** — Terraform CI (`plan`/`apply`)
- **OIDC (OpenID Connect)** / workload identity federation — passwordless Terraform auth

## CLI & Tooling

- **Azure CLI** (`az`) — login, resource management, onboarding
- **GitHub CLI** (`gh`) — repo management

## Security & Compliance

- **Azure Policy** — compliance dashboard
- **Azure RBAC** — service principal + least-privilege roles
- **Lynis** — OS-level CIS-style audit report (detect)
- **Ansible CIS roles** — apply/remediate CIS baselines (enforce)
- **Secrets management** — `.env` (gitignored) + GitHub Actions Secrets
