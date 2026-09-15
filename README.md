# Azure Arc Hybrid Governance Lab

Build and demonstrate **hybrid governance as code** — patch, audit, tagging, and RBAC — by onboarding on-premises servers to Azure Arc. The entire governance stack runs at **$0/month** (only the optional hybrid-networking Azure VM adds ~$2/month).

## Overview

A hands-on lab that simulates **2 on-premises servers** (Ubuntu 22.04 LTS VMs running locally in Multipass) and onboards them to Azure Arc, then layers on governance using only free Azure services. The result is a repeatable, infrastructure-as-code demonstration of how a hybrid datacenter gets centralized patching, compliance, tagging, and RBAC — with no per-server licensing.

| Capability | Tool | Cost |
|---|---|---|
| Virtualization | Multipass VM (CLI, Apple Silicon native) | Free |
| Onboarding & inventory | Azure Arc control plane | Free |
| Policy-as-code | Azure Policy (resource-level) | Free |
| Patch assessment + scheduling | Azure Update Manager | Free |
| Minimal log collection | Log Analytics (DCR) | Free (5 GB/month) |
| OS security audit | Lynis (open-source) | Free |
| Infrastructure provisioning | Terraform | Free |
| CIS hardening | Ansible (ansible-lockdown) | Free |
| CI/CD | GitHub Actions | Free (public repo) |
| Hybrid networking | Tailscale (mesh VPN) + Azure VM | Free + ~$2/month |

## What this lab demonstrates

- **Hybrid onboarding** — connect on-premises Linux servers to Azure Arc with `azcmagent`.
- **Infrastructure as code** — provision the resource group, tags, and Log Analytics workspace with Terraform.
- **Policy as code** — enforce tagging, region, and agent state with Azure Policy, and show a compliant vs. non-compliant machine side by side.
- **Centralized patching** — assess and schedule patches across hybrid servers with Azure Update Manager.
- **Cost-aware logging** — collect only what's needed via a data collection rule (DCR) to stay under the 5 GB/month free allowance.
- **Open-source security audit** — run Lynis CIS audits, replacing the paid Machine Configuration.
- **Hybrid networking** — connect local VMs to an Azure VM over a Tailscale mesh VPN.

## Why $0 works

- The **Azure Arc control plane** and **Azure Policy evaluation** are free.
- **Azure Update Manager** is free for Arc-enabled servers.
- **Log Analytics** includes 5 GB/month free (31-day retention); the DCR is scoped to stay under it.
- We deliberately avoid **Machine Configuration** (Guest Configuration), which costs $6/server/month for Arc servers. OS-level CIS checks use open-source **Lynis** instead.

See [docs/PRD.md](docs/PRD.md) for the full cost verification and the corrections made to the original plan.

## Architecture

```
Local Host (Apple Silicon M3 Pro)                         Azure
┌────────────────────────────────┐      HTTPS     ┌────────────────────────────────┐
│  Multipass (2 × Ubuntu 22.04)  │      (443)     │  Arc control plane (free)      │
│   ├─ VM-01                     ├───────────────▶│    · inventory, RBAC, tags      │
│   └─ VM-02                     │   azcmagent    │  Azure Policy (free) ×3        │
│        (Azure Connected         │                │  Azure Update Manager (free)  │
│         Machine agent)          │                │  Log Analytics (free 5 GB)    │
└────────────────────────────────┘                └────────────────────────────────┘
        │  Tailscale mesh VPN (100.x)
        └──────────▶ Azure VM (B1ls) — hybrid networking, ~$2/month
```

**Responsibility boundary:**

- **Terraform** manages Azure-side resources (resource group, tags, policies, workspace).
- **`onboard-linux.sh`** runs `azcmagent connect` inside each VM.
- **Lynis** performs OS security audits locally — no Azure cost.

## Milestones

| # | Milestone | What it does | Status |
|---|---|---|---|
| M0 | Local environment | Create 2 Ubuntu 22.04 arm64 VMs with Multipass | ✅ |
| M1 | Arc onboarding | Run `onboard-linux.sh` to connect both VMs to Azure Arc | ✅ |
| M2 | Terraform IaC | Provision resource group + tags + Log Analytics workspace | ✅ |
| M3 | Azure Policy | Assign 3 policies (tag / region / AMA) | 🔄 assigned |
| M4 | Update Manager | Patch assessment + scheduled patching | ✅ |
| M5 | Log Analytics (minimal) | Install AMA + scoped DCR | ⬜ |
| M6 | CI/CD | GitHub Actions terraform-ci (OIDC) | ⬜ |
| M7 | Security audit | Lynis + Ansible CIS hardening | 🔄 audit done |
| M8 | Presentation site | Astro site on Cloudflare Pages | ⬜ |
| M9 | Hybrid networking | Tailscale + Azure VM (B1ls) | ⏸️ capacity |

## Current status

**M0 ✅ · M1 ✅ · M2 ✅ · M3 ✅ · M4 ✅ · Tailscale mesh ✅**

```
Name    State    IPv4 (local)    IPv4 (Tailscale)   Image
vm-01   Running  192.168.252.4   100.122.67.121     Ubuntu 22.04 LTS
vm-02   Running  192.168.252.5   100.111.237.108    Ubuntu 22.04 LTS
```

VM specs (each): 2 vCPU / 2 GB RAM / 8 GB disk — actual usage ~1.9 GiB disk, ~170 MiB RAM.

Tailscale mesh verified: `ping` vm-01 ↔ vm-02 (0% packet loss, direct connection).

| Component | Status |
|---|---|
| Azure Arc machines | ✅ 2 Connected (vm-01, vm-02) |
| Service principal | ✅ `arc-onboarding-sp` (Azure Connected Machine Onboarding) |
| Log Analytics workspace | ✅ `arc-hybrid-lab-ws` (PerGB2018) |
| Azure Policy | ✅ 3 assigned (tag / region / AMA) |
| Azure Update Manager | ✅ assessment + weekly schedule (Sat 02:00 KST) |
| Lynis security audit | ✅ hardening index 59 (both VMs) |
| Azure VM (`cloud-vm`) | ⏸️ not provisioned (B-series capacity) |

## Governance policies (M3)

Three resource-level Azure Policies are assigned to the `arc-hybrid-lab` resource group:

| Policy | Definition | Effect | Purpose |
|---|---|---|---|
| `require-env-tag` | *Require a tag on resources* | deny | Denies resources missing the `env` tag |
| `allowed-locations` | *Allowed locations* | deny | Restricts resources to `koreacentral` |
| `ama-audit-linux-arc` | *Linux Arc machines should have AMA installed* | audit | Flags Arc servers without the Azure Monitor Agent |

> 💡 **Demo:** `vm-01` is tagged `env=lab` (compliant); `vm-02` is intentionally left untagged to surface as non-compliant in the Policy Compliance dashboard.
>
> 🛡️ **Governance in action:** the `require-env-tag` deny policy rejected a real resource — an Azure Update Manager maintenance configuration — the instant it was created without the `env` tag, proving enforcement (not just reporting).

## Getting started

### Prerequisites

- macOS with Apple Silicon (arm64)
- [Multipass](https://multipass.run/) — local VM manager
- [Azure CLI](https://learn.microsoft.com/cli/azure/) (`az login`)
- [Terraform](https://www.terraform.io/) (≥ 1.5)
- [GitHub CLI](https://cli.github.com/) (`gh`)

### Reproduce the lab

```bash
git clone https://github.com/scale600/azure-arc-hybrid.git
cd azure-arc-hybrid

# M0 — create 2 local VMs
./scripts/setup-vms.sh

# M1 — onboard both VMs to Azure Arc
# Requires a service principal with the "Azure Connected Machine Onboarding" role.
# The script is run inside each VM (see header for required env vars).
multipass transfer scripts/onboard-linux.sh vm-01:/tmp/ && multipass exec vm-01 -- sudo bash /tmp/onboard-linux.sh
multipass transfer scripts/onboard-linux.sh vm-02:/tmp/ && multipass exec vm-02 -- sudo bash /tmp/onboard-linux.sh

# M2–M3 — provision Azure resources + assign policies
cd terraform
terraform init
terraform plan
terraform apply
```

See [docs/CHECKLIST.md](docs/CHECKLIST.md) for the full, itemized build checklist.

## Repository structure

```
azure-arc-hybrid/
├── terraform/                 # Azure IaC
│   ├── main.tf                # RG + workspace + policy module
│   ├── variables.tf           # input variables
│   ├── outputs.tf             # outputs
│   ├── provider.tf            # azurerm provider
│   └── modules/
│       ├── resource-group/    # RG + tags
│       └── policy/            # 3 policy assignments
├── scripts/
│   ├── setup-vms.sh           # M0: install Multipass + create VMs
│   └── onboard-linux.sh       # M1: Arc onboarding (idempotent)
├── docs/
│   ├── PRD.md                 # requirements + cost verification
│   ├── CHECKLIST.md           # itemized build checklist
│   └── TECH_STACK.md          # technology choices
└── .env                       # Azure connection info (gitignored)
```

Planned (not yet scaffolded): `scripts/cis-audit/` (M7), `.github/workflows/` (M6/M8), `site/` (M8).

## Documentation

- [docs/PRD.md](docs/PRD.md) — product requirements, architecture, and $0 cost verification
- [docs/CHECKLIST.md](docs/CHECKLIST.md) — itemized build checklist with milestone status
- [docs/TECH_STACK.md](docs/TECH_STACK.md) — technology choices and rationale

## License

MIT
