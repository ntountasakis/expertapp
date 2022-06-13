FROM ubuntu:22.04 AS base
WORKDIR /node
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  nodejs \
  npm \
  protobuf-compiler \
  vim-tiny
COPY ./server/scripts ./scripts
COPY ./server/package.json ./
COPY ./server/tsconfig.json ./
COPY ./server/src ./src/
COPY ../protos ./protos_defs
RUN npm install
RUN npm run build

FROM base AS production
WORKDIR /server
COPY --from=0 ./node/package.json ./
RUN npm install --only=production
COPY --from=0 /node/dist .
WORKDIR /server/src

RUN mkdir conf
ARG GOOGLE_APPLICATION_CREDENTIALS
RUN if [[ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]] ; then echo "Credentials not provided" ;\
else  echo "$GOOGLE_APPLICATION_CREDENTIALS" > credentials.json ; fi

EXPOSE 8080
CMD ["node", "app.js"]
