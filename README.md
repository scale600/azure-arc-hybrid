# Azure Arc Hybrid Governance Lab

Build and demonstrate **hybrid governance as code** — patch, audit, tagging, and RBAC — by onboarding local VMs to Azure Arc. Entirely **$0/month**.

## What this is

A hands-on lab that simulates 2 on-premises servers (Ubuntu 22.04 VMs) and onboards them to Azure Arc, then layers on governance using only free Azure services:

| Capability | Tool | Cost |
|---|---|---|
| Onboarding & inventory | Azure Arc control plane | Free |
| Policy-as-code (tagging, region, agent state) | Azure Policy (resource-level) | Free |
| Patch assessment + scheduling | Azure Update Manager | Free |
| Minimal log collection | Log Analytics (DCR) | Free (5GB/month) |
| OS security audit | Lynis (open-source) | Free |
| Infrastructure provisioning | Terraform | Free |
| CI/CD | GitHub Actions | Free (public repo) |

## Why $0 works

- The **Azure Arc control plane** and **Azure Policy evaluation** are free.
- **Azure Update Manager** is free for Arc-enabled servers.
- We deliberately avoid **Machine Configuration** (Guest Configuration), which costs $6/server/month for Arc servers — OS-level CIS checks are done with open-source **Lynis** instead.

See [docs/PRD.md](docs/PRD.md) for the full cost verification and corrections to the original plan.

## Architecture

```
Local Host (Apple Silicon M3 Pro)                Azure
┌─────────────────────────────┐       ┌──────────────────────────────┐
│  Multipass                   │       │  Arc control plane (free)    │
│   ├─ VM-01 Ubuntu 22.04     │ HTTPS │   · inventory, RBAC, tags     │
│   └─ VM-02 Ubuntu 22.04     ├──────▶│  Azure Policy (free) ×3       │
│        azcmagent (Arc agent) │  443  │  Azure Update Manager (free)  │
└─────────────────────────────┘       │  Log Analytics (free 5GB)     │
                                      └──────────────────────────────┘
```

## Platform note

The host is Apple Silicon (ARM64), so x86_64 Windows Server cannot run natively. The lab uses **All-Linux (Ubuntu 22.04 LTS)** with **Multipass** for fast, native ARM VMs.

## Quick start

| Stage | Action |
|---|---|
| **M0** | Install Multipass, create 2× Ubuntu 22.04 arm64 VMs (2 vCPU / 2GB / 8GB) |
| **M1** | Run `scripts/onboard-linux.sh` on each VM to connect to Azure Arc |
| **M2** | Configure Terraform (`terraform/`) and run `terraform apply` |
| **M3** | Assign 3 Azure Policies (tag / region / AMA) |
| **M4** | Enable Update Manager patch assessment |
| **M5** | Configure minimal DCR for Log Analytics |
| **M6** | Set up GitHub Actions terraform-ci (OIDC) |
| **M7** | Run Lynis audit + document results |

## Repository structure

```
azure-arc-hybrid-lab/
├── terraform/            # Azure IaC (RG, tags, policies, workspace)
├── scripts/
│   ├── onboard-linux.sh  # Arc onboarding
│   └── cis-audit/        # Lynis audit
├── docs/                 # PRD, architecture
├── .github/workflows/    # Terraform CI
└── .env                  # Azure connection info (gitignored)
```

## License

MIT
