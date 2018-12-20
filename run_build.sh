#!/bin/bash

aws cloudformation create-stack --stack-name builder --template-body file://CFN_stacks/build_stack.yaml --parameters file://CFN_stacks/stack_config.json