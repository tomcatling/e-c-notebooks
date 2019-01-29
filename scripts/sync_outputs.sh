#!/bin/bash

set -e

bucket=$(aws cloudformation describe-stacks --stack-name e-c-notebooks-infrastructure --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::S3BucketName'].OutputValue" --output text)

aws s3 sync s3://"$bucket"/outputs/notebooks/ ./outputs
