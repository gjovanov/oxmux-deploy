# oxmux-deploy

Kubernetes deployment manifests for [Oxmux](https://github.com/gjovanov/oxmux).

Follows the same pattern as
[lgr-deploy](https://github.com/gjovanov/lgr-deploy) and
[roomler-ai-deploy](https://github.com/gjovanov/roomler-ai-deploy).

## Structure

```
oxmux-deploy/
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml          # non-secret config (ports, realm, etc.)
│   ├── secret.yaml.example     # secret template (never commit real values)
│   ├── deployment.yaml         # oxmux-server Deployment
│   ├── service.yaml            # ClusterIP + NodePort for WS/QUIC
│   ├── ingress.yaml            # HTTPS ingress (cert-manager)
│   └── hpa.yaml                # HorizontalPodAutoscaler
└── scripts/
    ├── deploy.sh               # apply all manifests in order
    ├── rollback.sh             # rollback to previous deployment
    └── seal-secrets.sh         # seal secrets with kubeseal
```

## Quick Deploy

```bash
# 1. Create secret from your .env values
cp k8s/secret.yaml.example k8s/secret.yaml
vim k8s/secret.yaml   # fill in base64-encoded values

# 2. Deploy
./scripts/deploy.sh

# 3. Verify
kubectl -n oxmux get pods
kubectl -n oxmux get ingress
```

## Triggered automatically

The [oxmux CI](https://github.com/gjovanov/oxmux/actions) dispatches a
`repository_dispatch` event to this repo on every successful main branch build.
The deploy workflow here receives it and applies the new image tag.

## Secret Management

All secrets originate from `.env` values and are stored in a Kubernetes Secret.
For production, seal them with [kubeseal](https://github.com/bitnami-labs/sealed-secrets):

```bash
./scripts/seal-secrets.sh
# Produces k8s/sealed-secret.yaml — safe to commit
```

The `COTURN_AUTH_SECRET` must match the value in your
[k8s-cluster-multi](https://github.com/gjovanov/k8s-cluster-multi) deployment.
