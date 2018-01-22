#!/bin/bash
# Set input vars from config.properties file
# NOTE: You will need to check this out from the lodgement-container-ui-config repo separately
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

cd "$SCRIPT_DIR/../.."  # Now one level above scripts/config dirs
AWS_REGION=ap-southeast-2 docker-credential-ecr-login list
docker build\
  -f container-scripts/Dockerfile \
  -t $IMAGE_NAME:$IMAGE_VERSION \
  --build-arg "NODE_VERSION=$NODE_VERSION" \
  --build-arg "FIREFOX_VERSION=$FIREFOX_VERSION" \
  --build-arg "WEBDRIVER_VERSION=$WEBDRIVER_VERSION" \
  --build-arg "JAVA_VERSION=$JAVA_VERSION" \
  --build-arg "PHANTOMJS_VERSION=$PHANTOMJS_VERSION" \
  --build-arg "NODE_PACKAGES=$NODE_PACKAGES" \
  .