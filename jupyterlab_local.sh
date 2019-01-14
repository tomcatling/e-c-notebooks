#!/bin/bash
set -eo pipefail

image_tag=$(aws cloudformation describe-stacks --stack-name e-c-notebooks-infrastructure --query \
"Stacks[0].Outputs[?ExportName=='ECNotebooks::ImageTagExport'].OutputValue" --output text)

$(aws ecr get-login --no-include-email)
echo "Pulling $image_tag"
docker pull $image_tag
IMAGE_TAG=$image_tag docker-compose -f docker/docker-compose.yaml up
