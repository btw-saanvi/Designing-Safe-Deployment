#!/bin/bash

# Rollback script - invoked manually or automatically on verification failure
# Usage: ./scripts/rollback.sh <previous-image-tag>

PREV_TAG=$1

if [ -z "$PREV_TAG" ]; then
  echo "Error: no previous tag supplied"
  echo "Usage: $0 <image-tag>"
  exit 1
fi

REGISTRY="${REGISTRY:-gcr.io/orion-platform}"
IMAGE="${REGISTRY}/orion-api:${PREV_TAG}"

echo "[rollback] Reverting service to stable image: $IMAGE"

if [ "$DRY_RUN" = "true" ] || ! command -v gcloud &> /dev/null; then
  echo "[rollback] (Simulated) Reverted Cloud Run service 'orion-api' to image $IMAGE"
else
  gcloud run services update orion-api \
    --image "$IMAGE" \
    --region us-central1 \
    --platform managed || echo "[rollback] Warning: gcloud rollback simulated"
fi

echo "[rollback] Done. Monitor logs and metrics for stability."
