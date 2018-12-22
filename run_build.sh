#!/bin/bash
set -eo pipefail

aws cloudformation create-stack --stack-name builder --template-body file://CFN_stacks/build-stack.yaml --parameters file://CFN_stacks/stack-config.json

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name builder

public_ip=$(CFN_stacks/get_stack_export.sh BuildPublicIp)  

echo "...builder is running at: ${public_ip}"