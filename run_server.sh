#!/bin/bash

aws cloudformation create-stack --stack-name jupyterlab --template-body file://CFN_stacks/server-stack.yaml --parameters file://CFN_stacks/stack-config.json

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name jupyterlab
stack_outputs=$(aws cloudformation get-stack --stack-name jupyterlab)
public_ip=$(echo $stack_outputs | python -c "import sys, json; print(json.load(sys.stdin)['Outputs']['PublicIP'])")
echo "...server is running at: ${public_ip}."