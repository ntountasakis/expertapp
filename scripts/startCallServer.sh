
#!/bin/bash

set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

ROOT=$(git rev-parse --show-toplevel)
source "${ROOT}/server/scripts/buildServerDockerImage.sh"

function startServerDockerContainer {
  echo "Building & running server docker container locally"
  buildLocalDockerImage
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
