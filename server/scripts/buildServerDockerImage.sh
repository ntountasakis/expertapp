#!/bin/bash
# exit when any command fails
set -e

DOCKER_CONTEXT=$(git rev-parse --show-toplevel)
IMAGE_NAME='expertapp-server'
PROJECT_NAME='expert-app-backend'
REPO_IMAGE_NAME="us-docker.pkg.dev/${PROJECT_NAME}/gcr.io/${IMAGE_NAME}"


buildDockerImage() {
    docker build -t $REPO_IMAGE_NAME $DOCKER_CONTEXT
}

uploadToArtifactRegistry() {
    docker push $REPO_IMAGE_NAME
}

while getopts "bu" opt; do
    case $opt in
    b)
	echo "Building docker image"
	buildDockerImage
	;;
    u)
	echo "Uploading docker image to artifact registry"
	uploadToArtifactRegistry
	;;
    esac
done
