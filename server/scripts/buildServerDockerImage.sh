#!/bin/bash
# exit when any command fails
set -e

DOCKER_CONTEXT=$(git rev-parse --show-toplevel)
IMAGE_NAME='expertapp-server'
PROJECT_NAME='expert-app-backend'
REPO_IMAGE_NAME="us-docker.pkg.dev/${PROJECT_NAME}/gcr.io/${IMAGE_NAME}:latest"


buildDockerImage() {
    docker build -t $REPO_IMAGE_NAME $DOCKER_CONTEXT
}

uploadToArtifactRegistry() {
    docker push $REPO_IMAGE_NAME
}

runLocalDockerContainer() {
  docker run -d --env PORT=8080 -p 8080:8080 -t $REPO_IMAGE_NAME
}

stopDockerContainer() {
  docker rm $(docker stop $(docker ps -a -q --filter ancestor=${REPO_IMAGE_NAME} --format="{{.ID}}"))
}

while getopts "burs" opt; do
    case $opt in
    b)
	echo "Building docker image"
	buildDockerImage
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
