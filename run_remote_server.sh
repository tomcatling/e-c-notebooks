#!/bin/bash

aws cloudformation create-stack --stack-name jupyterlab --template-body file://CFN_stacks/server-stack.yaml --parameters file://CFN_stacks/stack-config.json

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name jupyterlab

public_ip=$(aws cloudformation describe-stacks --stack-name jupyterlab --query \
"Stacks[0].Outputs[?OutputKey=='ServerPublicIp'].OutputValue" --output text)

echo "...server is running at: ${public_ip}:8888"