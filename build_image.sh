#!/bin/bash
set -eo pipefail

if [ ! -f ./tempkey.pem ]; then
	echo "Creating ssh key..."
	aws ec2 delete-key-pair --key-name e-c-notebooks
	sleep 2
	aws ec2 create-key-pair --key-name e-c-notebooks --query 'KeyMaterial' --output text > tempkey.pem
	sleep 2
	chmod 400 tempkey.pem
fi

my_ip=$(dig @resolver1.opendns.com A myip.opendns.com +short -4)

aws cloudformation create-stack --stack-name e-c-notebooks-builder \
--template-body file://cloudformation/build-stack.yaml \
--parameters ParameterKey=InstanceType,ParameterValue=t2.large \
ParameterKey=SSHLocation,ParameterValue=$my_ip/32 \
ParameterKey=Timeout,ParameterValue=3600 \
--capabilities CAPABILITY_NAMED_IAM

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name e-c-notebooks-builder

if [ -z $AWS_PROFILE ]; then 
	public_ip=$(aws cloudformation describe-stacks --stack-name e-c-notebooks-builder --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::BuildPublicIp'].OutputValue" --output text)
else 
	public_ip=$(AWS_PROFILE=$AWS_PROFILE aws cloudformation describe-stacks --stack-name e-c-notebooks-builder --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::BuildPublicIp'].OutputValue" --output text)
fi

echo "Connect to instance using:"
echo "ssh -i tempkey.pem ec2-user@${public_ip}"