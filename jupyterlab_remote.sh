#!/bin/bash

my_ip=$(dig @resolver1.opendns.com A myip.opendns.com +short -4)

aws cloudformation create-stack --stack-name e-c-notebooks-jupyterlab \
--template-body file://cloudformation/server-stack.yaml \
--parameters ParameterKey=InstanceType,ParameterValue=t2.large \
ParameterKey=SSHLocation,ParameterValue=$my_ip/32 \
ParameterKey=Timeout,ParameterValue=3600 \
--capabilities CAPABILITY_NAMED_IAM

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name e-c-notebooks-jupyterlab


if [ -z $AWS_PROFILE ]; then 
	public_ip=$(aws cloudformation describe-stacks --stack-name jupyterlab --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::ServerPublicIp'].OutputValue" --output text)
else 
	public_ip=$(AWS_PROFILE=$AWS_PROFILE aws cloudformation describe-stacks --stack-name jupyterlab --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::ServerPublicIp'].OutputValue" --output text)
fi



echo "...server is running at: ${public_ip}:8888"
