#!/bin/bash

aws cloudformation create-stack --stack-name jupyterlab \
--template-body file://cloudformation/server-stack.yaml --parameters $(cat cloudformation/config)

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name e-c-notebooks-jupyterlab

public_ip=$(aws cloudformation describe-stacks --stack-name jupyterlab --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::ServerPublicIp'].OutputValue" --output text)

echo "...server is running at: ${public_ip}:8888"
