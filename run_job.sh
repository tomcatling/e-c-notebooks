#!/bin/bash#!/usr/bin/env bash
set -eo pipefail

IPYNB_FILE=${1}

usage() {
	cat <<-EOF

	Usage: $0 <path to notebook>
	  e.g.
	  $0 notebooks/example.ipynb
	EOF
	return
}

fail_exit() {
  echo ${1}
  usage
  exit 1
}

if [ -z "$IPYNB_FILE" ]; then
	fail_exit "Notebook file not specified"
fi

if [ ! -f "$IPYNB_FILE" ]; then
    fail_exit "File: ${IPYNB_FILE} - does not exist"
fi

stackname=e-c-notebooks-job-$(date "+%Y%m%d%H%M%S")

# Add in the notebook path as an additional parameter.
# Replace spaces with #, can't seem to pass them in otherwise
aws cloudformation create-stack --stack-name $stackname \
--template-body file://cloudformation/job-stack.yaml \
--parameters $(cat cloudformation/config) \
ParameterKey=NotebookJobPath,ParameterValue=$(echo ${IPYNB_FILE} | sed 's/ /#SPACE#/g')

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name $stackname

public_ip=$(aws cloudformation describe-stacks --stack-name $stackname --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::$stackname::JobPublicIp'].OutputValue" --output text)

bucket=$(aws cloudformation describe-stacks --stack-name $stackname --query \
"Stacks[0].Outputs[?OutputKey=='ECNotebooks::S3BucketName'].OutputValue" --output text)

echo "...job is running at: ${public_ip}"
echo "Output will be placed in S3://$bucket/$IPYNB_FILE/$stackname.ipynb"
