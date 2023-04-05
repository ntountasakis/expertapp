FROM ubuntu:22.04 AS base
WORKDIR /server
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  npm \
  protobuf-compiler \
  vim-tiny \
  curl
RUN npm install -g n && n 18
COPY ./server/call_transaction/package.json ./call_transaction/
COPY ./server/call_transaction/tsconfig.json ./call_transaction/
COPY ./server/shared/package.json ./shared/
WORKDIR /server/call_transaction
RUN npm i
WORKDIR /server/shared
RUN npm i
WORKDIR /server
COPY ./conf ./conf/
COPY ./server/scripts ./call_transaction/scripts
COPY ./server/call_transaction/src ./call_transaction/src
COPY ./server/shared/src ./shared/src
COPY ../protos ./call_transaction/protos_defs
WORKDIR /server/call_transaction
RUN npm run build
WORKDIR /server/call_transaction/dist/call_transaction/src/
ARG IS_PROD_ARG
ARG STRIPE_PRIVATE_KEY_VERSION_ARG
ENV IS_PROD=$IS_PROD_ARG
ENV STRIPE_PRIVATE_KEY_VERSION=$STRIPE_PRIVATE_KEY_VERSION_ARG
EXPOSE 8080
ENTRYPOINT node app.js
