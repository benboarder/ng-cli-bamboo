#!/bin/bash
set -x

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
source "$SCRIPT_DIR/../../config/config.properties"

BRANCH_NAME="${bamboo_planRepository_1_branch}"
echo "Branch name = ${BRANCH_NAME}"
echo "Build number = ${bamboo_buildNumber}"

if [ "$BRANCH_NAME" == "master" ]; then
  IMAGE_VERSION="${MAJOR_VERSION}.${bamboo_buildNumber}"
else
  IMAGE_VERSION="${BRANCH_NAME}-${bamboo_buildNumber}"
fi

IMAGE_URI="149659705229.dkr.ecr.ap-southeast-2.amazonaws.com/$IMAGE_NAME"

docker tag $IMAGE_NAME:$IMAGE_VERSION $IMAGE_URI:$IMAGE_VERSION
docker push $IMAGE_URI:$IMAGE_VERSION