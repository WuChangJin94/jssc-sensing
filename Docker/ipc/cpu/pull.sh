#!/usr/bin/env bash
set -euo pipefail

REPOSITORY="jssc-sensing"
TAG="x86-noetic-v1.0"

IMG="${REPOSITORY}:${TAG}"

echo "Pulling image: ${IMG}"
docker pull "${IMG}"