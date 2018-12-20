#!/bin/bash

aws cloudformation create-stack --stack-name builder --template-body file://CFN_stacks/build-stack.yaml --parameters file://CFN_stacks/stack-config.json