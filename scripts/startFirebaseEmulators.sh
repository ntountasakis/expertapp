#!/bin/bash

set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

ROOT=$(git rev-parse --show-toplevel)
source "${ROOT}/server/scripts/serverDockerImageUtil.sh"

DATA_DIR="${SCRIPTPATH}/emulatorData/"
mkdir -p ${DATA_DIR}
echo "Starting firebase emulators with data dir: ${DATA_DIR}"

firebase emulators:start --inspect-functions --import=${DATA_DIR} --export-on-exit=${DATA_DIR}
