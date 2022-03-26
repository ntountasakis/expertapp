FROM node:17-alpine AS base
WORKDIR /node
COPY package.json ./
COPY tsconfig.json ./
COPY src ./src
RUN ls -a
RUN npm install
RUN npm run build

FROM base as production
WORKDIR /usr
COPY package.json ./
RUN npm install --only=production
RUN ls -a
COPY --from=0 /node/build .
RUN ls -a
CMD ["node", "app.js"]
