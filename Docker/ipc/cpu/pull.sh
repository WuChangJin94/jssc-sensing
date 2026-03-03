#!/usr/bin/env bash

REPOSITORY="argnctu/moos-dawg-2024"
TAG="ubuntu20.04_IPC"

IMG="${REPOSITORY}:${TAG}"

docker pull "${IMG}"
