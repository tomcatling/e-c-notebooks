#!/bin/bash
set -eo pipefail

EXPORT_NAME=${1}

stack_outputs=$(aws cloudformation list-exports)
return=$(echo $stack_outputs | python -c "import sys, json; \
exports=json.load(sys.stdin)['Exports'];\
export_str=str([i['Value'] for i in exports if i.get('Name')=='${EXPORT_NAME}']);\
print(export_str.replace('\'','').lstrip('[').rstrip(']'))")
echo "$return"