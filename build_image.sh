#!/bin/bash
set -eo pipefail

aws cloudformation create-stack --stack-name builder \
--template-body file://cloudformation/build-stack.yaml --parameters $(cat cloudformation/config)

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name builder

public_ip=$(aws cloudformation describe-stacks --stack-name builder --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::BuildPublicIp'].OutputValue" --output text)

echo "...builder is running at: ${public_ip}"
