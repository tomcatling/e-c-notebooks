#!/bin/bash

aws cloudformation create-stack --stack-name infrastructure --template-body file://CFN_stacks/infrastructure-stack.yaml --parameters file://CFN_stacks/stack-config.json

echo "Waiting for stack creation to finish..."
aws cloudformation wait stack-create-complete --stack-name infrastructure

git_addr=$(cat .git/config | grep url | awk -F '=' '{print $2}' | head -n 1)

stack_outputs=$(aws cloudformation get-stack --stack-name infrastructure)
cc_addr=$(echo $stack_outputs | python -c "import sys, json; print(json.load(sys.stdin)['Outputs']['CodeCommitAddress'])")

echo "Adding CodeCommit as a push destination for origin..."
echo ${cc_addr}

git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

git remote remove origin
git remote add origin ${git_addr}
git remote set-url --add --push origin ${git_addr}
git remote set-url --add --push origin ${cc_addr}

echo "Initial push..."

git push origin master

echo "...Done."

