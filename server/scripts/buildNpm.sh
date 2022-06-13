#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source $SCRIPTPATH/functions/protoBufs.sh

WORK_DIR="/node/"
DIST_DIR="${WORK_DIR}/dist/"

PROTO_DEFS="${WORK_DIR}/protos_defs/"
PROTO_OUT="${WORK_DIR}/generated/protos/"
NODE_BIN="${WORK_DIR}/node_modules/.bin/"

generateProtoBufs ${NODE_BIN} ${PROTO_DEFS} ${PROTO_OUT}
tsc -p .

mkdir -p "${DIST_DIR}"
cp -r ${PROTO_DEFS} "${DIST_DIR}/protos"
