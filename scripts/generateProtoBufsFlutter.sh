#!/bin/bash
mkdir -p lib/src/generated/protos
protoc -I protos/ protos/call_transaction.proto --dart_out=grpc:lib/src/generated/protos/
