#!/bin/bash

echo "Creating infrastructure stack..."

#aws cloudformation create-stack --stack-name infrastructure2 --template-body file://CFN_stacks/infrastructure-stack.yaml --capabilities CAPABILITY_IAM

echo "Waiting for stack creation to finish. This will take a few minutes..."
#aws cloudformation wait stack-create-complete --stack-name infrastructure2

git_addr=$(cat .git/config | grep url | awk -F '=' '{print $2}' | head -n 1)

stack_outputs=$(aws cloudformation list-exports)
cc_addr=$(echo $stack_outputs | python -c "import sys, json; \
exports=json.load(sys.stdin)['Exports'];\
export_str=str([i['Value'] for i in exports if i.get('Name')=='CodeCommitAddress']);\
print(export_str.replace('\'','').lstrip('[').rstrip(']'))")

image_tag=$(echo $stack_outputs | python -c "import sys, json; \
exports=json.load(sys.stdin)['Exports'];\
export_str=str([i['Value'] for i in exports if i.get('Name')=='ImageTagExport']);\
print(export_str.replace('\'','').lstrip('[').rstrip(']'))")

image_tag_ESC=$(sed 's/[\*\.\/]/\\&/g' <<<"$image_tag")

echo "$image_tag_ESC"

sed "s/image: none/image: $image_tag_ESC/" docker-compose.yaml > docker-compose.yaml.tmp
mv docker-compose.yaml.tmp docker-compose.yaml

echo "Adding a remote called codecommit..."
echo "git remote add codecommit ${cc_addr}"
git remote add codecommit ${cc_addr}

git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

echo "Initial push..."
echo "git push codecommit master"
git push codecommit master

echo "...Done."

