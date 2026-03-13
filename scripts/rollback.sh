#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="oxmux"
REVISION="${1:-}"

if [[ -n "${REVISION}" ]]; then
  echo "Rolling back to revision ${REVISION}..."
  kubectl rollout undo deployment/oxmux -n "${NAMESPACE}" --to-revision="${REVISION}"
else
  echo "Rolling back to previous revision..."
  kubectl rollout undo deployment/oxmux -n "${NAMESPACE}"
fi

kubectl rollout status deployment/oxmux -n "${NAMESPACE}" --timeout=120s
echo "✅ Rollback complete"
kubectl get pods -n "${NAMESPACE}"
