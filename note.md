# Hybrid Arc Governance Lab — expected cost: $0/month

> Original planning notes. See [docs/PRD.md](docs/PRD.md) for the corrected, finalized plan.

Minimum-cost strategy: the Azure Arc control plane is completely free. RBAC, tagging, inventory, and Azure Policy evaluation are all free. Guest Configuration policies are also free up to 5 per server/month. Update Manager is also provided free for Arc-enabled servers.

Implementation:

- **Local VMs:** create Windows Server 2022 + Ubuntu 22.04 with VirtualBox/VMware (free)
- **Azure Arc onboarding:** connect local VMs to Arc with `azcmagent connect` (free)
- **Azure Policy:** limit to ≤5 CIS Benchmark-based policies (free)
- **Monitoring:** Log Analytics is free up to 5GB/month → collect minimal logs only

GitHub repo structure:

```
azure-arc-hybrid-lab/
├── terraform/
│   ├── modules/arc-server/     # Arc onboarding automation
│   └── policies/               # CIS Benchmark policies (≤5)
├── scripts/
│   ├── onboard-windows.ps1     # Windows Arc onboarding
│   └── onboard-linux.sh        # Linux Arc onboarding
├── docs/ARCHITECTURE.md
└── .github/workflows/terraform-ci.yml  # Public repo → Actions free
```

Interview story: "I onboarded 3 on-premises servers to Azure Arc in a local lab environment and automated the patch/audit process with Terraform + Policy. Since the Arc control plane is free, hybrid governance can be built with no cost burden even in financial services."
