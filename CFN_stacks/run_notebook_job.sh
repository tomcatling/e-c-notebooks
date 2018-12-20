#!/usr/bin/env bash
set -eo pipefail

IPYNB_FILE=${1}
IMAGE_TAG=${2}

NB_PATH=${IPYNB_FILE} IMAGE_TAG=${IMAGE_TAG} docker-compose -f ../docker-compose.yml -f headless-compose-override.yml up --exit-code-from jupyterlab --no-color