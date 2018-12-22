#!/bin/bash
set -eo pipefail

stack_outputs=$(aws cloudformation list-exports)
image_tag=$(echo $stack_outputs | python -c "import sys, json; \
exports=json.load(sys.stdin)['Exports'];\
export_str=str([i['Value'] for i in exports if i.get('Name')=='ImageTagExport']);\
print(export_str.replace('\'','').lstrip('[').rstrip(']'))")

$(aws ecr get-login --no-include-email)
echo "Pulling $image_tag"
docker pull $image_tag
docker-compose up
