#!/bin/bash
set -eo pipefail

echo "Creating infrastructure stack..."

aws cloudformation create-stack --stack-name infrastructure --template-body file://CFN_stacks/infrastructure-stack.yaml --capabilities CAPABILITY_IAM

echo "Waiting for stack creation to finish. This will take a few minutes..."
aws cloudformation wait stack-create-complete --stack-name infrastructure

git_addr=$(cat .git/config | grep url | awk -F '=' '{print $2}' | head -n 1)

cc_addr=$(CFN_stacks/get_stack_export.sh CodeCommitAddress)

echo "Adding a remote called codecommit..."
echo "git remote add codecommit ${cc_addr}"
git remote add codecommit ${cc_addr}

git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

echo "Initial push..."
echo "git push codecommit master"
git push codecommit master

echo "...Done."

