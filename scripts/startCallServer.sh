
#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

IS_PROD=$1
STRIPE_PRIVATE_KEY_VERSION=$2

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

ROOT=$(git rev-parse --show-toplevel)
source "${ROOT}/server/scripts/serverDockerImageUtil.sh"

function startServerDockerContainer {
  echo "Building & running server docker container locally"
  buildDockerImage $IS_PROD $STRIPE_PRIVATE_KEY_VERSION
  echo "Running docker container"
  runLocalDockerContainer
  echo "local name $LOCAL_NAME"
}

function shutdown()
{
    echo "shutting down"
    echo "Killing docker grpc server"
    stopDockerContainer
}

trap 'shutdown' SIGINT SIGTERM

startServerDockerContainer
docker logs -f $LOCAL_NAME

wait
