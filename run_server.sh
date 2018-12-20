#!/bin/bash

aws cloudformation create-stack --stack-name jupyterlab --template-body file://CFN_stacks/server-stack.yaml --parameters file://CFN_stacks/stack-config.json