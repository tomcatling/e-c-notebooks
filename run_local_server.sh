#!/bin/bash
set -eo pipefail

image_tag=$(CFN_stacks/get_stack_export.sh ImageTagExport)  


$(aws ecr get-login --no-include-email)
echo "Pulling $image_tag"
docker pull $image_tag
IMAGE_TAG=$image_tag docker-compose up
