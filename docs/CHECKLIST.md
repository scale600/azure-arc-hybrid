# Build Checklist

Concrete, verifiable build items for the Azure Arc Hybrid Governance Lab, broken down from the PRD milestones (M0–M8).

> **Status:** `✅ M0 complete` · Last updated 2026-09-15
>
> Legend: `[ ]` = not done · `[x]` = done

---

## Prerequisites

- [x] Azure account with an active subscription (tenant/subscription recorded in `.env`)
- [x] Apple Silicon macOS host (M3 Pro) with Multipass installed
- [x] CLIs installed: `az`, `gh`, `terraform` (≥1.5), `ansible`
- [x] GitHub repo `scale600/azure-arc-hybrid` cloned locally
- [ ] Cloudflare account with access to the `techcloudup.com` zone

---

## M0 — Local environment

**Done when:** 2 Ubuntu VMs are reachable over SSH and Azure billing has a $0 alert.

- [x] Install Multipass (`brew install --cask multipass`)
- [x] Create `VM-01` with Multipass (2 vCPU / 2 GB / 8 GB)
- [x] Create `VM-02` with Multipass (same spec)
- [x] Confirm outbound HTTPS (443) works from both VMs (Multipass NAT network)
- [x] SSH into both VMs from the host
- [x] Set a **$0 budget alert** in Azure Cost Management
- [x] Verify `az account show` returns the lab subscription

---

## M1 — Arc onboarding

**Done when:** both VMs show `Connected` in Azure Portal → Azure Arc → Machines.

- [ ] Install the Azure Connected Machine agent on `VM-01`
- [ ] Install the Azure Connected Machine agent on `VM-02`
- [ ] Create a service principal with the minimal role needed for onboarding
- [ ] Run `azcmagent connect` on `VM-01`
- [ ] Run `azcmagent connect` on `VM-02`
- [ ] Verify both machines appear as `Connected` in the Arc portal
- [x] Write `scripts/onboard-linux.sh` (idempotent + parameterized)
- [ ] Write an Ansible onboarding playbook using `azure.azcollection`

---

## M2 — Terraform IaC

**Done when:** `terraform apply` provisions the resource group, tags, and workspace.

- [ ] Scaffold `terraform/` with the `azurerm` provider (+ backend config)
- [ ] Define a `resource-group` module (with `env=lab` tag)
- [ ] Define a Log Analytics workspace
- [ ] Run `terraform init`, `validate`, and `plan` cleanly
- [ ] Run `terraform apply` and verify resources in the Azure Portal

---

## M3 — Azure Policy

**Done when:** the Compliance dashboard flags `VM-02` (missing tag) as non-compliant.

- [ ] Policy 1 — require tag `env=lab` (built-in or custom)
- [ ] Policy 2 — allowed locations
- [ ] Policy 3 — Azure Monitor Agent extension audit on Arc machines
- [ ] Assign all 3 policies to the resource group **via Terraform**
- [ ] Verify `VM-01` = compliant, `VM-02` = non-compliant in the Policy dashboard

---

## M4 — Update Manager

**Done when:** patch assessment and scheduled patching work for both servers.

- [ ] Enable Azure Update Manager for the Arc servers (free)
- [ ] Run a patch assessment on both VMs
- [ ] Configure a scheduled patch (maintenance window)
- [ ] Verify patch results in Update Manager

---

## M5 — Log Analytics (minimal)

**Done when:** ingestion stays well under 5 GB/month and cost remains $0.

- [ ] Install Azure Monitor Agent (AMA) on both VMs
- [ ] Create a DCR scoped to minimal data (Syslog errors + selected security events)
- [ ] Associate the DCR with both Arc machines
- [ ] Verify daily ingestion is far below the 5 GB/month free allowance
- [ ] Confirm monthly cost stays $0 in Cost Management

---

## M6 — CI/CD

**Done when:** `terraform plan` runs in GitHub Actions on push/PR.

- [ ] Set up GitHub Actions **OIDC** (federated credential to Azure — no secrets)
- [ ] Write `.github/workflows/terraform-ci.yml` (plan on PR, apply on merge)
- [ ] Verify CI runs `terraform plan` successfully

---

## M7 — Security audit (Lynis + Ansible)

**Done when:** audit reports exist in `docs/` and CIS remediation improves the score.

- [ ] Install Lynis on both VMs
- [ ] Run the audit and store reports in `docs/`
- [ ] Apply the `ansible-lockdown` UBUNTU22-CIS role via Ansible
- [ ] Re-run Lynis to confirm the remediation improved the hardening score

---

## M8 — Presentation site

**Done when:** the site is live at `azure-arc-hybrid.techcloudup.com` with auto-refreshed snapshots.

- [ ] Scaffold an Astro site in `site/` (Tailwind CSS)
- [ ] Build pages: overview, architecture, compliance, cost
- [ ] Write `.github/workflows/snapshot.yml` (scheduled `az graph` / `az policy` queries → JSON)
- [ ] Render snapshot JSON in the site
- [ ] Create a Cloudflare Pages project linked to the GitHub repo
- [ ] Attach the custom domain `azure-arc-hybrid.techcloudup.com` (auto DNS via Cloudflare)
- [ ] Verify the site is live and snapshots refresh on schedule

---

## Progress summary

| Milestone | Scope | Status |
|---|---|---|
| M0 | Local environment (Multipass + VMs) | ✅ |
| M1 | Arc onboarding | ⬜ |
| M2 | Terraform IaC | ⬜ |
| M3 | Azure Policy | ⬜ |
| M4 | Update Manager | ⬜ |
| M5 | Log Analytics (minimal) | ⬜ |
| M6 | CI/CD | ⬜ |
| M7 | Lynis + Ansible CIS | ⬜ |
| M8 | Presentation site | ⬜ |
