#!/bin/bash

aws cloudformation create-stack --stack-name jupyterlab --template-body file://CFN_stacks/server-stack.yaml --parameters file://CFN_stacks/stack-config.json

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name jupyterlab
stack_outputs=$(aws cloudformation list-exports)
public_ip=$(echo $stack_outputs | python -c "import sys, json; \
exports=json.load(sys.stdin)['Exports'];\
export_str=str([i['Value'] for i in exports if i.get('Name')=='ServerPublicIp']);\
print(export_str.replace('\'','').lstrip('[').rstrip(']'))")
echo "...server is running at: ${public_ip}:8888"