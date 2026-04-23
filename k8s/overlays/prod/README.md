# oxmux prod overlay

ArgoCD will sync this path. The base lives under `../../base`.

## Image tag

Each successful build on mars should bump `newTag` here and commit to the `oxmux-deploy` repo.
ArgoCD detects the commit, reconciles the Deployment, the pod pulls the new image from
`registry.roomler.ai/oxmux:<tag>` and rolls.

## Secrets

The `oxmux-secret` Secret is NOT managed here. Provision it once via `kubectl create secret ...`
(out-of-band). Phase 4 will replace this with a SealedSecret committed to the repo.
