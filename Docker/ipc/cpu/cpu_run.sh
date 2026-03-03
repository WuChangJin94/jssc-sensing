#!/usr/bin/env bash
set -euo pipefail

ARGS=("$@")

REPOSITORY="jssc-sensing"
TAG="x86-noetic-v1.0"
IMG="${REPOSITORY}:${TAG}"

USER_NAME="jetseaai"
REPO_NAME="jssc-sensing"
CONTAINER_NAME="jssc-sensing-x86-noetic-v1.0"

# ------------------------------------------------------------
# If container already exists, exec into it
# ------------------------------------------------------------
CONTAINER_ID="$(docker ps -aqf "name=^${CONTAINER_NAME}$" || true)"
if [[ -n "${CONTAINER_ID}" ]]; then
  echo "Attach to docker container ${CONTAINER_NAME}"
  xhost + >/dev/null 2>&1 || true
  docker exec --privileged \
    -e DISPLAY="${DISPLAY:-:0}" \
    -e LINES="$(tput lines 2>/dev/null || echo 40)" \
    -it "${CONTAINER_NAME}" \
    bash
  xhost - >/dev/null 2>&1 || true
  exit 0
fi

# ------------------------------------------------------------
# X11 authentication (optional, safe even if unused)
# ------------------------------------------------------------
XAUTH=/tmp/.docker.xauth
if [[ ! -f "${XAUTH}" ]]; then
  touch "${XAUTH}"
  chmod a+r "${XAUTH}"

  if command -v xauth >/dev/null 2>&1; then
    xauth_list="$(xauth nlist "${DISPLAY:-:0}" 2>/dev/null || true)"
    xauth_list="$(sed -e 's/^..../ffff/' <<<"${xauth_list}")"
    if [[ -n "${xauth_list}" ]]; then
      echo "${xauth_list}" | xauth -f "${XAUTH}" nmerge - >/dev/null 2>&1 || true
    fi
  fi
fi

if [[ ! -f "${XAUTH}" ]]; then
  echo "[${XAUTH}] was not properly created. Exiting..."
  exit 1
fi

# ------------------------------------------------------------
# Run container
# ------------------------------------------------------------
xhost + >/dev/null 2>&1 || true

docker run \
  -it \
  --rm \
  -e DISPLAY="${DISPLAY:-:0}" \
  -e XAUTHORITY="${XAUTH}" \
  -e HOME="/home/${USER_NAME}" \
  -e USER="root" \
  -v "${XAUTH}:${XAUTH}" \
  -v "/home/${USER}/${REPO_NAME}:/home/${USER_NAME}/${REPO_NAME}" \
  -v "/tmp/.X11-unix:/tmp/.X11-unix" \
  -v "/etc/localtime:/etc/localtime:ro" \
  -v "/dev:/dev" \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  --user "root:root" \
  --workdir "/home/${USER_NAME}/${REPO_NAME}" \
  --name "${CONTAINER_NAME}" \
  --network host \
  --privileged \
  --security-opt seccomp=unconfined \
  "${IMG}" \
  bash

xhost - >/dev/null 2>&1 || true