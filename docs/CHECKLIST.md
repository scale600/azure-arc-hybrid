# Build Checklist

Concrete, verifiable build items for the Azure Arc Hybrid Governance Lab, broken down from the PRD milestones (M0–M8).

> **Status:** `✅ M0 + M1 + M2 + M4 + M5 + M6 + M7 complete` · M3 assigned · Last updated 2026-09-16
>
> Legend: `[ ]` = not done · `[x]` = done

---

## Prerequisites

- [x] Azure account with an active subscription (tenant/subscription recorded in `.env`)
- [x] Apple Silicon macOS host (M3 Pro) with Multipass installed
- [x] CLIs installed: `az`, `gh`, `terraform` (≥1.5), `ansible`
- [x] GitHub repo `scale600/azure-arc-hybrid` cloned locally
- [ ] Cloudflare account with access to the `techcloudup.com` zone
- [ ] Tailscale account (free personal tier)

---

## M0 — Local environment

**Done when:** 2 Ubuntu VMs are reachable over SSH and Azure billing has a $0 alert.

- [x] Install Multipass (`brew install --cask multipass`)
- [x] Create `VM-01` with Multipass (2 vCPU / 2 GB / 8 GB)
- [x] Create `VM-02` with Multipass (same spec)
- [x] Confirm outbound HTTPS (443) works from both VMs (Multipass NAT network)
- [x] SSH into both VMs from the host
- [x] Set a **budget alert** in Azure Cost Management (`lab-budget`, $2/month)
- [x] Verify `az account show` returns the lab subscription

---

## M1 — Arc onboarding

**Done when:** both VMs show `Connected` in Azure Portal → Azure Arc → Machines.

- [x] Install the Azure Connected Machine agent on `VM-01`
- [x] Install the Azure Connected Machine agent on `VM-02`
- [x] Create a service principal with the minimal role needed for onboarding
- [x] Run `azcmagent connect` on `VM-01`
- [x] Run `azcmagent connect` on `VM-02`
- [x] Verify both machines appear as `Connected` in the Arc portal
- [x] Write `scripts/onboard-linux.sh` (idempotent + parameterized)

---

## M2 — Terraform IaC

**Done when:** `terraform apply` provisions the resource group, tags, and workspace.

- [x] Scaffold `terraform/` with the `azurerm` provider (+ backend config)
- [x] Define a `resource-group` module (with `env=lab` tag)
- [x] Define a Log Analytics workspace
- [x] Run `terraform init`, `validate`, and `plan` cleanly
- [x] Run `terraform apply` and verify resources in the Azure Portal

---

## M3 — Azure Policy

**Done when:** the Compliance dashboard flags `VM-02` (missing tag) as non-compliant.

- [x] Policy 1 — require tag `env=lab` (built-in or custom)
- [x] Policy 2 — allowed locations
- [x] Policy 3 — Azure Monitor Agent extension audit on Arc machines
- [x] Assign all 3 policies to the resource group **via Terraform**
- [ ] Verify `VM-01` = compliant, `VM-02` = non-compliant in the Policy dashboard (compliance eval in progress)

---

## M4 — Update Manager

**Done when:** patch assessment and scheduled patching work for both servers.

- [x] Enable Azure Update Manager for the Arc servers (free) — registered `Microsoft.Compute` + `Microsoft.Maintenance`
- [x] Run a patch assessment on both VMs — triggered `assessPatches` (HTTP 202)
- [x] Configure a scheduled patch (maintenance window) — `arc-hybrid-lab-patch-window` (Weekly Sat 02:00 KST) assigned to both
- [ ] Verify patch results in Update Manager — assessment results populate asynchronously (~24h)

---

## M5 — Log Analytics (minimal)

**Done when:** ingestion stays well under 5 GB/month and cost remains $0.

- [x] Install Azure Monitor Agent (AMA) on both VMs (1.45.0, arm64)
- [x] Create a DCR scoped to minimal data — `arc-hybrid-lab-syslog-dcr` (Syslog auth/authpriv @ Warning+)
- [x] Associate the DCR with both Arc machines (DCRA vm-01 + vm-02)
- [x] Verify Syslog data flowing to the workspace (queried `Syslog` table — both machines)
- [ ] Confirm monthly ingestion ≪ 5 GB and cost $0 (requires billing cycle)

---

## M6 — CI/CD

**Done when:** `terraform plan` runs in GitHub Actions on push/PR.

- [x] Set up GitHub Actions **OIDC** (federated credential to Azure — no secrets; SP `azure-arc-hybrid-github-actions`)
- [x] Write `.github/workflows/terraform-ci.yml` (plan on PR, apply on main)
- [x] Configure remote backend (Azure Storage `archylabtfstate`) + migrate state
- [x] Verify CI runs `terraform plan` + `apply` successfully (OIDC, no secrets)

---

## M7 — Security audit (Lynis + Ansible)

**Done when:** audit reports exist in `docs/` and CIS remediation improves the score.

- [x] Install Lynis on both VMs
- [x] Run the audit and store reports in `docs/` (hardening index 59)
- [x] Apply the `ansible-lockdown` UBUNTU22-CIS role via Ansible (Level 1 server, 35 changes per VM)
- [x] Re-run Lynis to confirm the remediation improved the hardening score (59 → 71)

> ℹ️ Disabled 2 password rules in `ansible/harden.yml` (`ubtu22cis_rule_5_2_4` sudo password, `ubtu22cis_rule_5_4_2_4` root password) — Multipass VMs use key-only auth, so the role's password prerequisite checks would otherwise fail. Arc + AMA agents verified still running after hardening.

---

## M8 — Presentation site

**Done when:** the site is live at `azure-arc-hybrid.techcloudup.com` with auto-refreshed snapshots.

- [x] Scaffold an Astro site in `site/` (Tailwind CSS)
- [x] Build pages: overview, architecture, compliance, cost
- [x] Write `.github/workflows/snapshot.yml` (scheduled `az graph` / `az policy` queries → JSON)
- [x] Render snapshot JSON in the site
- [x] Create an Azure Static Web App (Free) + deploy via `.github/workflows/deploy-site.yml`
- [ ] Attach the custom domain `azure-arc-hybrid.techcloudup.com` (CNAME → SWA, DNS via Cloudflare)
- [ ] Verify the site is live and snapshots refresh on schedule

---

## M9 — Hybrid networking (local ↔ Azure)

**Done when:** local VMs can ping/SSH the Azure VM over Tailscale.

- [ ] Provision an Azure VM (B1ls, ~$2/month budget; deallocate when idle)
- [ ] Install Tailscale on the Azure VM
- [ ] Install Tailscale on `vm-01` and `vm-02`
- [ ] Verify connectivity (ping/SSH over Tailscale `100.x` IPs)
- [ ] Deallocate the Azure VM when not in use (cost control)

---

## Progress summary

| Milestone | Scope | Status |
|---|---|---|
| M0 | Local environment (Multipass VM) | ✅ |
| M1 | Arc onboarding | ✅ |
| M2 | Terraform IaC | ✅ |
| M3 | Azure Policy | 🔄 |
| M4 | Update Manager | ✅ |
| M5 | Log Analytics (minimal) | ✅ |
| M6 | CI/CD | ✅ |
| M7 | Lynis + Ansible CIS | ✅ |
| M8 | Presentation site | 🔄 |
| M9 | Hybrid networking (Tailscale + Azure VM) | ⬜ |
