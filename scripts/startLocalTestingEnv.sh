#!/bin/bash

set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

ROOT=$(git rev-parse --show-toplevel)
source "${ROOT}/server/scripts/buildServerDockerImage.sh"

function startFirebaseEmulators() {
  DATA_DIR="${SCRIPTPATH}/emulatorData/"
  mkdir -p ${DATA_DIR}
  echo "Starting firebase emulators with data dir: ${DATA_DIR}"

  firebase emulators:start --import=${DATA_DIR} --export-on-exit=${DATA_DIR} &
  FIREBASE_PID=$!

  sleep 10
}

function startServerDockerContainer {
  echo "Building & running server docker container locally"
  buildDockerImage
  runLocalDockerContainer
}

function shutdown()
{
    echo "shutting down"
    echo "Killing firebase pid ${FIREBASE_PID}"
    kill ${FIREBASE_PID}
    echo "Killing docker grpc server"
    stopDockerContainer
}

trap 'shutdown' SIGINT SIGTERM

startFirebaseEmulators
startServerDockerContainer

wait
