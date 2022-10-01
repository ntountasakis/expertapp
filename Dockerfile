FROM ubuntu:20.04 AS base
WORKDIR /node
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  nodejs \
  npm \
  protobuf-compiler \
  vim-tiny
COPY ./server/scripts ./scripts
COPY ./server/call_transaction/package.json ./
COPY ./server/call_transaction/tsconfig.json ./
COPY ./server/call_transaction/src ./src/
COPY ../protos ./protos_defs
RUN npm install
RUN npm run build

FROM base AS production
WORKDIR /server
COPY --from=0 ./node/package.json ./
RUN npm install --only=production
COPY --from=base /node/dist .
WORKDIR /server/src
COPY ./conf ./conf
EXPOSE 8080
ENTRYPOINT ["node", "app.js"]
