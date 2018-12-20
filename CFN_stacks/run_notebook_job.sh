#!/usr/bin/env bash
set -eo pipefail

IPYNB_FILE=${1}

usage() {
	cat <<-EOF

	Usage: $0 <path to notebook>
	  e.g.
	  $0 notebooks/examples/loading_data_from_datalake.ipynb
	EOF
	return
}

fail_exit() {
  echo ${1}
  usage
  exit 1
}

if [ -z ${IPYNB_FILE} ]; then
	fail_exit "Notebooks file not specified"
fi

if [ ! -f ${IPYNB_FILE} ]; then
    fail_exit "File: ${IPYNB_FILE} - does not exist"
fi

SCRIPT_PATH=${IPYNB_FILE} docker-compose -f ../docker/docker-compose-headless-job.yml --exit-code-from jupyter --no-color up