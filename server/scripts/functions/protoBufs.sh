#!/bin/bash

set -e
set -x

function generateProtoBufs()
{
    local NODE_BIN=$1
    local PROTO_DEFS=$2
    local PROTO_OUT=$3
    
    mkdir -p $PROTO_OUT

    ${NODE_BIN}/proto-loader-gen-types \
    --longs=String \
    --enums=String \
    --defaults \
    --oneofs \
    --grpcLib=@grpc/grpc-js \
    --outDir=${PROTO_OUT} \
    ${PROTO_DEFS}/*.proto
}
