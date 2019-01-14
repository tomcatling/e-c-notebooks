#!/bin/bash
set -eo pipefail

aws cloudformation create-stack --stack-name e-c-notebooks-builder \
--template-body file://cloudformation/build-stack.yaml --parameters $(cat cloudformation/config)

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name e-c-notebooks-builder

public_ip=$(aws cloudformation describe-stacks --stack-name e-c-notebooks-builder --query \
"Stacks[0].Outputs[?ExportName=='BuildPublicIp'].OutputValue" --output text)

echo "...builder is running at: ${public_ip}"
