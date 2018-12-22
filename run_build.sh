#!/bin/bash

aws cloudformation create-stack --stack-name builder --template-body file://CFN_stacks/build-stack.yaml --parameters file://CFN_stacks/stack-config.json

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name builder
stack_outputs=$(aws cloudformation get-stack --stack-name builder)
public_ip=$(echo $stack_outputs | python -c "import sys, json; print(json.load(sys.stdin)['Outputs']['PublicIP'])")
echo "...job is running at: ${public_ip}."