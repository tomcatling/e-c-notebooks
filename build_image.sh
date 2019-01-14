#!/bin/bash
set -eo pipefail


aws cloudformation create-stack --stack-name e-c-notebooks-builder \
--template-body file://cloudformation/build-stack.yaml --parameters $(cat cloudformation/config) \
--capabilities CAPABILITY_IAM

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name e-c-notebooks-builder

public_ip=$(AWS_PROFILE=$AWS_PROFILE aws cloudformation describe-stacks --stack-name e-c-notebooks-builder --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::BuildPublicIp'].OutputValue" --output text)

echo "...builder is running at: ${public_ip}"
