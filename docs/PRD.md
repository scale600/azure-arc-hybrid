# PRD — Hybrid Arc Governance Lab

> Build and demonstrate hybrid governance (patch/audit/tagging/RBAC as code) by onboarding local VMs to Azure Arc.
> Expected cost: **$0/month** (verified configuration)

---

## 1. Executive Summary

Onboard 2 local VMs (simulating on-premises servers) to Azure Arc, and combine Terraform (IaC) + Azure Policy (free) + Azure Update Manager (free) to build **hybrid governance — patch/audit/tagging/RBAC managed as code**. Because the Azure Arc control plane and Azure Policy evaluation are free, the lab can genuinely run at $0/month as long as OS-level Guest Configuration (Machine Configuration) is not used.

**Core principle: keep $0 = do NOT use Machine Configuration (paid, $6/server/month); use only free features (Azure Policy resource-level evaluation, Arc inventory, Update Manager).**

**Platform constraint:** the host is Apple Silicon (M3 Pro), so x86_64-only Windows Server cannot run natively → use **All-Linux (Ubuntu 22.04 LTS × 2)**.

**Presentation:** the final deliverable is a static presentation site at [azure-arc-hybrid.techcloudup.com](https://azure-arc-hybrid.techcloudup.com) hosted on Cloudflare Pages, with CI-generated compliance/cost snapshots.

**Hybrid networking:** local VMs connect to an Azure VM over a Tailscale mesh VPN (free), demonstrating hybrid cloud connectivity. The Azure VM adds up to $2/month (deallocate when idle).

---

## 2. note.md Review — Required Corrections

| # | note.md original claim | Verification | Action |
|---|---|---|---|
| 1 | "Guest Configuration policies free up to 5 per server/month" | ❌ **Incorrect.** Machine Configuration is **$6/server/month** for Arc servers (pro-rated hourly, no free tier). Free only for Azure VMs. | Exclude OS-level Guest Configuration. Replace with free Azure Policy (resource-level). |
| 2 | "Azure Policy evaluation all free" | ✅ Correct (resource-level policy evaluation is free) | Keep |
| 3 | "Inventory free" | ⚠️ Partially correct. Arc **core inventory** is free. "Change Tracking & Inventory" is a $6/server/month bundle. | Use core inventory only. Change tracking is out of scope. |
| 4 | "Update Manager free" | ✅ Correct (free GA for Azure VMs and Arc servers) | Keep — core of patch management |
| 5 | "Log Analytics 5GB/month free" | ✅ Correct (5GB/month per billing account, 31-day retention) | Keep — but data collection must be minimized |
| 6 | "Local VM free (Windows Server 2022)" | ❌ **Platform mismatch.** Windows Server (x86) cannot run natively on M3 Pro (ARM); emulation is impractical | Replace with **All-Linux (Ubuntu ×2)** |
| 7 | "5 CIS Benchmark-based policies" | ⚠️ OS-level CIS checks require Machine Configuration ($6) | Use **Lynis (open-source) + bash script** for free audit reports |
| 8 | Server count mismatch (impl "2" vs story "3") | ❌ Inconsistent | **Standardize on 2** (Ubuntu 22.04 × 2) |
| 9 | "3 on-premises servers" | ⚠️ Actually local VMs | Phrase honestly as "on-premises simulation (2 local VMs)" |
| 10 | Terraform role ambiguous | Terraform manages Azure resources (IaC). Onboarding runs `azcmagent` inside the VM. | Clarify boundary (§5) |

---

## 3. Goals & Non-goals

### In Scope
1. Onboard 2 local VMs (Ubuntu 22.04 LTS) to Azure Arc
2. Codify Azure resources (resource group, tags, policy assignments) with Terraform
3. Enforce resource-level governance (tagging, region, agent status) with Azure Policy (free)
4. Automate patch assessment + scheduled patching with Azure Update Manager (free)
5. Organize resources with RBAC + tags
6. Minimal Log Analytics collection (within 5GB)
7. Terraform CI/CD with GitHub Actions (public repo → free)
8. Generate OS security audit reports with Lynis (open-source), replacing Machine Configuration
9. Publish a static presentation site at azure-arc-hybrid.techcloudup.com (Cloudflare Pages) with CI-refreshed compliance/cost snapshots
10. Connect local VMs to an Azure VM via Tailscale mesh VPN (hybrid networking, ≤$2/month)

### Out of Scope
- Machine Configuration (Guest Configuration) OS-level policies — **paid ($6/server/month), excluded**
- Windows Server VM — impractical on Apple Silicon
- Microsoft Defender for Servers / Sentinel — paid
- Change Tracking & Inventory (detailed change tracking) — paid bundle
- Azure Monitor VM Insights (full perf monitoring) — risks exceeding 5GB

---

## 4. Definition of Done

- [ ] 2 Ubuntu VMs appear as `Connected` in the Arc machines list in Azure Portal
- [ ] Required tag (`env=lab`) applied to all Arc resources
- [ ] A single `terraform apply` reproduces resource group + tags + policy assignments
- [ ] Non-compliant resources aggregate in the Azure Policy Compliance dashboard (3 resource-level policies)
- [ ] Update Manager shows patch assessment for 2 servers, and scheduled patching works
- [ ] Lynis audit report generated and stored in `docs/`
- [ ] Log Analytics monthly ingestion stays below 5GB
- [ ] GitHub Actions runs `terraform plan/apply` via OIDC
- [ ] Monthly Azure cost = $0 (verified in cost analysis)
- [ ] Presentation site live at azure-arc-hybrid.techcloudup.com with auto-refreshed snapshots

---

## 5. Architecture

```
┌─ Local Host (macOS / Apple Silicon M3 Pro) ─────────────┐
│  Multipass VM (Canonical CLI manager)                        │
│   ├─ VM-01  Ubuntu 22.04 LTS (arm64)  2vCPU/2GB/8GB     │
│   └─ VM-02  Ubuntu 22.04 LTS (arm64)  2vCPU/2GB/8GB     │
│        │  each VM: Azure Connected Machine Agent          │
│        │  (azcmagent connect → Azure Arc)                │
└────────┼─────────────────────────────────────────────────┘
         │ HTTPS (443, outbound)
┌────────▼─────────────────────────────────────────────────┐
│  Azure                                                    │
│   ├─ Arc control plane (free)                             │
│   │    · inventory, RBAC, tags                            │
│   ├─ Azure Policy (free, resource-level) — 3 policies     │
│   │    · required tag / allowed regions / AMA ext audit   │
│   ├─ Azure Update Manager (free)                          │
│   │    · patch assessment + scheduled patching            │
│   └─ Log Analytics (free 5GB/month)                       │
│        · minimal logs only (AMA + DCR)                    │
└───────────────────────────────────────────────────────────┘

Terraform (azurerm) — manages Azure-side resources only:
  resource group / tags / policy assignments / Log Analytics workspace / DCR
Onboarding script (inside VM) — runs azcmagent connect:
  onboard-linux.sh (same for both VMs)
Audit (inside VM, free) — Lynis:
  scripts/cis-audit/audit.sh → report to docs/
```

**Responsibility boundary:**
- **Terraform** = Azure resources (RG, tags, policies, workspace) IaC management
- **Onboarding script** = runs `azcmagent connect` inside the VM
- **Lynis** = OS security audit (free), runs locally, independent of Azure Policy
- **Ansible** = CIS hardening enforcement (ansible-lockdown roles), M7
- **GitHub Actions** = automates Terraform `plan/apply` (OIDC auth, no secrets)

> 💡 **Demo point:** configure VM-01 as compliant (tags + AMA installed) and VM-02 as intentionally non-compliant (missing tag), to show the "compliant vs non-compliant" contrast in the Azure Policy Compliance dashboard.

**Presentation layer (public, static):**

```
GitHub Actions (scheduled)            Cloudflare Pages
  az graph / policy queries  ──▶  snapshot JSON  ──▶  Astro build  ──▶  azure-arc-hybrid.techcloudup.com
  (OIDC, no secrets)           (committed to repo)   (custom domain via Cloudflare DNS)
```

- Static site (Astro) renders compliance / patch / cost snapshots produced by a scheduled CI job — no Azure credentials are ever exposed to the public site.

---

## 6. Cost Verification — $0 basis (as of 2026.09)

| Service | Rate | Note |
|---|---|---|
| Azure Arc control plane | **Free** | inventory, RBAC, tagging, Policy evaluation |
| Azure Policy (resource-level) | **Free** | definitions, assignments, evaluation |
| Azure Update Manager | **Free** | Arc server patch assessment + scheduled patching |
| Log Analytics | **Free 5GB/month** | per billing account, 31-day retention |
| ~~Machine Configuration~~ | ~~$6/server/month~~ | **not used** (excluded) |
| ~~Defender / Sentinel~~ | ~~paid~~ | **not used** (excluded) |
| OS | **Free** | Ubuntu 22.04 LTS (permanently free) |
| Virtualization | **Free** | Multipass VM (open-source) |
| CIS audit | **Free** | Lynis (open-source) |
| GitHub Actions | **Free** | public repo |
| Cloudflare Pages | **Free** | static hosting + custom domain |
| Tailscale | **Free** | mesh VPN (personal tier) |
| Azure VM (B1ls) | **~$2/month** | cloud-side node; deallocate when idle |

> ⚠️ **Prerequisite for $0:** unrestricted heartbeat/perf-counter ingestion into Log Analytics can exceed 5GB, so the DCR must minimize collected data (only some Syslog errors + security events).
>
> 💰 **The only non-$0 item is the optional Azure VM** (~$2/month, B1ls) for hybrid networking. Everything else is free; the VM is deallocated when not in use.

---

## 7. Milestones

| Stage | Content | Artifact | Free? |
|---|---|---|---|
| **M0** | Create 2 Ubuntu 22.04 arm64 VMs with Multipass; prepare Azure subscription | 2 VMs + `.env` | Free |
| **M1** | Write and run Arc onboarding script | `scripts/onboard-linux.sh` | Free |
| **M2** | Terraform IaC (RG, tags, Policy, workspace) | `terraform/` | Free |
| **M3** | 3 Azure Policy governance policies (tag/region/AMA) | `terraform/policies/` | Free |
| **M4** | Update Manager patch assessment + scheduled patching | update policy config | Free |
| **M5** | Minimal Log Analytics collection (AMA + DCR) | DCR definition | Free (≤5GB) |
| **M6** | GitHub Actions terraform-ci (OIDC) | `.github/workflows/terraform-ci.yml` | Free |
| **M7** | Lynis audit + documentation | `scripts/cis-audit/`, `docs/` | Free |
| **M8** | Static presentation site (Astro) + CI snapshots + Cloudflare Pages deploy | `site/`, `.github/workflows/snapshot.yml` | Free |
| **M9** | Hybrid networking: Azure VM (B1ls) + Tailscale mesh VPN | `cloud-vm`, Tailscale | ~$2/month |

---

## 8. Repository Structure

```
azure-arc-hybrid-lab/
├── terraform/
│   ├── modules/
│   │   ├── resource-group/       # RG + tags
│   │   └── policy/               # policy assignments (3 resource-level)
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars.example
├── scripts/
│   ├── setup-vms.sh              # M0: install Multipass + create VMs
│   ├── onboard-linux.sh          # Arc onboarding (shared by 2 VMs)
│   └── cis-audit/
│       └── audit.sh              # Lynis run + report collection
├── site/                         # static presentation site (Astro)
├── docs/
│   ├── PRD.md
│   ├── TECH_STACK.md
│   ├── CHECKLIST.md
│   └── ARCHITECTURE.md
├── .env                          # Azure connection info (gitignored)
├── .github/workflows/
│   ├── terraform-ci.yml
│   └── snapshot.yml              # az queries → snapshot JSON
└── README.md
```

---

## 9. Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Log Analytics exceeds 5GB | unexpected billing | minimize DCR collection + set a $0 budget alert |
| Ubuntu arm64 + azcmagent compatibility | onboarding failure | Ubuntu 22.04 arm64 is officially supported (verify immediately on M1) |
| Azure free-tier policy changes | breaks $0 | set a budget alert at M0 |
| Terraform→Azure auth | CI failure | GitHub Actions OIDC (workload identity), no secrets |
| Secrets hardcoded in onboarding script | security risk | service principal + least privilege; secrets only in `.env`/Actions Secrets |
| Multipass networking misconfiguration | VM↔internet failure | use Multipass default NAT network for outbound 443 |

---

## 10. Project Narrative

A personal, hands-on project to explore hybrid governance with Azure Arc: simulate 2 on-premises servers (Ubuntu 22.04) locally, onboard them to Azure Arc, and automate **tagging, auditing, and patching as code** with Terraform + Azure Policy + Update Manager. Because the Arc control plane and Policy evaluation are free, the whole setup runs at **$0/month**, with a public presentation dashboard at [azure-arc-hybrid.techcloudup.com](https://azure-arc-hybrid.techcloudup.com). The notable design choice was replacing the paid Machine Configuration with open-source Lynis for OS-level CIS checks to keep the cost at zero.

---

## 11. Decisions (finalized)

| Item | Decision | Rationale |
|---|---|---|
| VM config | **Ubuntu 22.04 LTS × 2 (All-Linux)** | Windows Server x86 can't run on Apple Silicon (M3); minimal & lightweight |
| Virtualization | **Multipass VM** | open-source, fully CLI (multipass launch/exec), Apple Silicon native |
| CIS audit | **Lynis (open-source) + bash script** | keeps $0 |
| Policies | **3** (required tag / allowed regions / AMA ext audit) | minimal set, all free resource-level policies |
| VM spec | 2 vCPU / 2GB / 8GB | 2 VMs total 4GB RAM; 8GB disk minimized for limited host storage |
| Presentation | **Static site (Astro) on Cloudflare Pages** | $0, custom domain via existing Cloudflare DNS, no Azure creds exposed |
| Domain | **azure-arc-hybrid.techcloudup.com** | subdomain of techcloudup.com (DNS on Cloudflare) |
| Hybrid networking | **Tailscale (free) + Azure VM (B1ls)** | mesh VPN for local↔Azure connectivity; VM ≤$2/month, deallocate when idle |
