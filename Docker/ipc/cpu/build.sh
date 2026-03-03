#!/usr/bin/env bash
set -euo pipefail

REPOSITORY="jssc-sensing"
TAG="x86-noetic-v1.0"

IMG="${REPOSITORY}:${TAG}"

# Get the full path and name of the script
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  SCRIPT_PATH="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_PATH/$SOURCE"
done
SCRIPT_PATH="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

# Check if the Dockerfile exists
if [ -f "${SCRIPT_PATH}/Dockerfile" ]; then
  DOCKERFILE_PATH="${SCRIPT_PATH}/Dockerfile"
elif [ -f "${SCRIPT_PATH}/dockerfile" ]; then
  DOCKERFILE_PATH="${SCRIPT_PATH}/dockerfile"
else
  echo "Parse dockerfile path error: Dockerfile not found"
  exit 1
fi

echo "=================================================="
BOLD_GREEN="\033[1;32m"
END_COLOR="\033[0m"
echo -e "Show Dockerfile:${BOLD_GREEN}\n"
cat "${DOCKERFILE_PATH}"
echo -e "${END_COLOR}"
echo "=================================================="
echo "Start building image: ${IMG}"

docker buildx build --rm --load "$@" \
  -f "${DOCKERFILE_PATH}" \
  -t "${IMG}" \
  "${SCRIPT_PATH}"