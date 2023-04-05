#!/bin/bash
# exit when any command fails
set -e

ROOT=$(git rev-parse --show-toplevel)
source "${ROOT}/server/scripts/serverDockerImageUtil.sh"

OPT_STR="p:v:burs"

while getopts $OPT_STR opt; do
    case $opt in
    p)
       IS_PROD=${OPTARG}
       echo "IS_PROD: $IS_PROD"
       ;;
    v)
        STRIPE_PRIVATE_KEY_VERSION=${OPTARG}
        echo "STRIPE_PRIVATE_KEY_VERSION: $STRIPE_PRIVATE_KEY_VERSION"
	;;
    esac
done

if [ -z "${IS_PROD}" ] || [ -z "${STRIPE_PRIVATE_KEY_VERSION}" ]; then
    echo "Illegal number of parameters"
    exit 1
fi

OPTIND=0
while getopts $OPT_STR opt; do
    case $opt in
    b)
	echo "Building prod docker image"
	buildDockerImage $IS_PROD $STRIPE_PRIVATE_KEY_VERSION
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
