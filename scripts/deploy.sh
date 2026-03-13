#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="oxmux"
K8S_DIR="$(cd "$(dirname "$0")/../k8s" && pwd)"

# Accept image tag from CI dispatch or use latest
IMAGE_TAG="${1:-latest}"
echo "Deploying oxmux image tag: ${IMAGE_TAG}"

# Apply manifests in dependency order
kubectl apply -f "${K8S_DIR}/namespace.yaml"
kubectl apply -f "${K8S_DIR}/configmap.yaml"

if [[ -f "${K8S_DIR}/secret.yaml" ]]; then
  kubectl apply -f "${K8S_DIR}/secret.yaml"
elif [[ -f "${K8S_DIR}/sealed-secret.yaml" ]]; then
  kubectl apply -f "${K8S_DIR}/sealed-secret.yaml"
else
  echo "WARNING: No secret.yaml or sealed-secret.yaml found. Ensure secrets exist in cluster."
fi

# Update image tag in deployment
kubectl set image deployment/oxmux \
  oxmux="ghcr.io/gjovanov/oxmux:${IMAGE_TAG}" \
  -n "${NAMESPACE}" || \
  kubectl apply -f "${K8S_DIR}/deployment.yaml"

kubectl apply -f "${K8S_DIR}/service.yaml"
kubectl apply -f "${K8S_DIR}/ingress.yaml"
kubectl apply -f "${K8S_DIR}/hpa.yaml"

# Wait for rollout
echo "Waiting for rollout..."
kubectl rollout status deployment/oxmux -n "${NAMESPACE}" --timeout=120s

echo "✅ Deployed oxmux:${IMAGE_TAG}"
kubectl get pods -n "${NAMESPACE}"
