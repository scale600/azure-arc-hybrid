#!/usr/bin/env bash
# Generate site/src/data/snapshot.json — Arc machines + policy compliance snapshot.
#
# Auth: assumes `az` is already logged in.
#   - Local:  run `az login` first, or rely on an existing session.
#   - CI:     `.github/workflows/snapshot.yml` logs in via OIDC before calling this.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT="$REPO_ROOT/site/src/data/snapshot.json"

# Local runs can pull values from .env; CI provides env vars directly.
if [[ -f "$REPO_ROOT/.env" ]]; then
  set -a; source "$REPO_ROOT/.env"; set +a
fi

RG="${AZURE_RESOURCE_GROUP:-arc-hybrid-lab}"
WS="${AZURE_WORKSPACE_NAME:-arc-hybrid-lab-ws}"

GENERATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
mkdir -p "$(dirname "$OUT")"

# 1) Arc-enabled machines (inventory + status + tags).
MACHINES="$(az graph query -q "resources | where type =~ 'microsoft.hybridcompute/machines' | project name, location, status=properties.status, osName=properties.osName, osVersion=properties.osVersion, tags" -o json)"

# 2) Policy compliance for the 3 lab assignments (aggregated compliant/non-compliant counts).
POLICIES="$(az policy state list --resource-group "$RG" -o json | jq -c '
  [.[] | select(.policyAssignmentName == "require-env-tag" or .policyAssignmentName == "allowed-locations" or .policyAssignmentName == "ama-audit-linux-arc")]
  | group_by(.policyAssignmentName)
  | map({ name: .[0].policyAssignmentName,
          compliant: (map(select(.complianceState == "Compliant")) | length),
          nonCompliant: (map(select(.complianceState == "NonCompliant")) | length) })
')"

# 3) Assemble the final snapshot. Policy metadata (display name + effect) is stable
#    (defined in terraform/) so it is declared here rather than re-queried.
jq -n \
  --arg generatedAt "$GENERATED_AT" \
  --arg workspace "$WS" \
  --argjson machines "$MACHINES" \
  --argjson policies "$POLICIES" \
  '{
    generatedAt: $generatedAt,
    machines: ($machines.data | map({
      name: .name,
      status: .status,
      location: .location,
      os: (if .osName == "linux" then "Ubuntu 22.04 LTS" else .osName end),
      kernel: .osVersion,
      tags: .tags
    })),
    policies: [
      (($policies[] | select(.name == "require-env-tag")) + { displayName: "Require env tag on resources", effect: "deny" }),
      (($policies[] | select(.name == "allowed-locations")) + { displayName: "Allowed locations", effect: "deny" }),
      (($policies[] | select(.name == "ama-audit-linux-arc")) + { displayName: "Linux Arc machines should have AMA installed", effect: "audit" })
    ],
    cost: { currency: "USD", monthlyTarget: 0, budgetAlertUSD: 2 },
    logAnalytics: { workspace: $workspace, freeTierGB: 5 }
  }' > "$OUT"

echo "Wrote $OUT"
