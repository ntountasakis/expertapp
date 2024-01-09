#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source $SCRIPTPATH/functions/protoBufs.sh

PROTO_DEFS=$(git rev-parse --show-toplevel)/protos/
PROTO_OUT=$(git rev-parse --show-toplevel)/server/call_transaction/generated/protos/
NODE_BIN=$(git rev-parse --show-toplevel)/server/call_transaction/node_modules/.bin/

generateProtoBufs ${NODE_BIN} ${PROTO_DEFS} ${PROTO_OUT}
