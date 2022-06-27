#!/bin/bash
# exit when any command fails
set -e

DOCKER_CONTEXT=$(git rev-parse --show-toplevel)
IMAGE_NAME='expertapp-server'
PROJECT_NAME='expert-app-backend'
REPO_IMAGE_NAME="us-docker.pkg.dev/${PROJECT_NAME}/gcr.io/${IMAGE_NAME}:latest"


buildDockerImage() {
    docker build \
    -t $REPO_IMAGE_NAME \
    $DOCKER_CONTEXT
}

buildLocalDockerImage() {
    docker build \
    --progress=plain \
    -t $REPO_IMAGE_NAME \
    $DOCKER_CONTEXT
}

uploadToArtifactRegistry() {
    docker push $REPO_IMAGE_NAME
}

runLocalDockerContainer() {
  # 9002 for local firestore emulator
  docker run -d --env PORT=8080 \
  --env GOOGLE_APPLICATION_CREDENTIALS='/server/src/conf/expert-app-localdev.json' \
  -p 8080:8080 \
  --add-host=host.docker.internal:host-gateway \
  -t $REPO_IMAGE_NAME &
}

stopDockerContainer() {
  docker rm $(docker stop $(docker ps -a -q --filter ancestor=${REPO_IMAGE_NAME} --format="{{.ID}}"))
}

while getopts "bdurs" opt; do
    case $opt in
    b)
	echo "Building prod docker image"
	buildDockerImage
	;;
    d)
	echo "Building dev local docker image"
	buildLocalDockerImage
	;;
    u)
	echo "Uploading docker image to artifact registry"
	uploadToArtifactRegistry
	;;
    r)
	echo "Running local docker image for testing"
	runLocalDockerContainer
	;;
    s)
	echo "Stopping local docker image for testing"
	stopDockerContainer
	;;
    esac
done
