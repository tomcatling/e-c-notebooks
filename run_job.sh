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

if [ -z "${IPYNB_FILE}" ]; then
	fail_exit "Notebook file not specified"
fi

if [ ! -f "${IPYNB_FILE}" ]; then
    fail_exit "File: ${IPYNB_FILE} - does not exist"
fi

stackname=headless-job-$(date "+%Y%m%d%H%M%S")

# Append the notebooks path to the parameters then reformat for inserting via cli
params=$(cat CFN_stacks/stack-config.json | python -c "\
import sys, json;\
param_list=json.load(sys.stdin);\
param_list.append({'ParameterKey': 'NotebookJobPath', 'ParameterValue': '${IPYNB_FILE}'.replace(' ','#')});\
param_string = str(['{}={}'.format(k,pair[k]) for pair in param_list for k in ['ParameterKey','ParameterValue']]);\
param_string = param_string.replace('\'','').lstrip('[').rstrip(']').replace(', ParameterKey',' ParameterKey').replace(' ParameterValue','ParameterValue');\
print(param_string)")

echo $params

aws cloudformation create-stack --stack-name ${stackname} \
--template-body file://CFN_stacks/job-stack.yaml --parameters $params

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name ${stackname}
stack_outputs=$(aws cloudformation list-exports)
public_ip=$(echo $stack_outputs | python -c "import sys, json; \
exports=json.load(sys.stdin)['Exports'];\
export_str=str([i['Value'] for i in exports if i.get('Name')=='${stackname}::JobPublicIp']);\
print(export_str.replace('\'','').lstrip('[').rstrip(']'))")
echo "...job is running at: ${public_ip}"

# get bucket name
bucket=$(echo $stack_outputs | python -c "import sys, json; \
exports=json.load(sys.stdin)['Exports'];\
export_str=str([i['Value'] for i in exports if i.get('Name')=='${stackname}::S3BucketName']);\
print(export_str.replace('\'','').lstrip('[').rstrip(']'))")

echo "Output will be placed in S3://${bucket}/${IPYNB_FILE}/${stackname}.ipynb"
