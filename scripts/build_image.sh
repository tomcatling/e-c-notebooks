#!/bin/bash
set -eo pipefail

my_ip=$(dig @resolver1.opendns.com A myip.opendns.com +short -4)

aws cloudformation create-stack --stack-name e-c-notebooks-builder \
--template-body file://cloudformation/build-stack.yaml \
--parameters ParameterKey=InstanceType,ParameterValue=t2.large \
ParameterKey=SSHLocation,ParameterValue=$my_ip/32 \
ParameterKey=Timeout,ParameterValue=3600 \
--capabilities CAPABILITY_NAMED_IAM

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name e-c-notebooks-builder

public_ip=$(aws cloudformation describe-stacks --stack-name e-c-notebooks-builder --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::BuildPublicIp'].OutputValue" --output text)

echo "Connect to instance using:"
echo "ssh -i instance_key.pem ec2-user@${public_ip}"