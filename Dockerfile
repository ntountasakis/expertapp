FROM ubuntu:20.04 AS base
WORKDIR /node
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  nodejs \
  npm \
  protobuf-compiler \
  vim-tiny
COPY ./server/scripts ./call_transaction/scripts
COPY ./server/call_transaction/package.json ./call_transaction/
COPY ./server/call_transaction/tsconfig.json ./call_transaction/
COPY ./server/call_transaction/src ./call_transaction/src
COPY ./server/shared ./shared/
COPY ../protos ./call_transaction/protos_defs
WORKDIR ./call_transaction/
RUN npm install
RUN npm run build

FROM base AS production
WORKDIR /server/
COPY --from=0 ./node/call_transaction/package.json ./
RUN npm install --only=production
COPY --from=base /node/call_transaction/dist .
COPY ./conf ./src/conf/
WORKDIR /server/call_transaction/src
EXPOSE 8080
ENTRYPOINT ["node", "app.js"]
