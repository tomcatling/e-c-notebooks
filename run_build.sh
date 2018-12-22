#!/bin/bash
set -eo pipefail

aws cloudformation create-stack --stack-name builder --template-body file://CFN_stacks/build-stack.yaml --parameters file://CFN_stacks/stack-config.json

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name builder


stack_outputs=$(aws cloudformation list-exports)
public_ip=$(echo $stack_outputs | python -c "import sys, json; \
exports=json.load(sys.stdin)['Exports'];\
export_str=str([i['Value'] for i in exports if i.get('Name')=='BuildPublicIp']);\
print(export_str.replace('\'','').lstrip('[').rstrip(']'))")

echo "...builder is running at: ${public_ip}"