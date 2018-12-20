#!/usr/bin/env bash
set -eo pipefail

IPYNB_FILE=${1}
IMAGE_TAG=${2}

NB_PATH=${IPYNB_FILE} IMAGE_TAG=${IMAGE_TAG} docker-compose -f ../docker/docker-compose-headless-job.yml up --exit-code-from jupyterlab --no-color