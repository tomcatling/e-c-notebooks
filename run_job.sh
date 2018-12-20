#!/bin/bash#!/usr/bin/env bash
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

aws cloudformation create-stack --stack-name headless-job --template-body file://CFN_stacks/job-stack.yaml --parameters file://CFN_stacks/stack-config.json