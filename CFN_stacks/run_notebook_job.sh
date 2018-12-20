#!/usr/bin/env bash
set -eo pipefail

IPYNB_FILE=${1}


NB_PATH=${IPYNB_FILE} docker-compose -f ../docker/docker-compose-headless-job.yml up --exit-code-from jupyter --no-color