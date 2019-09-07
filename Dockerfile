FROM node:12-alpine

# Install Hub
COPY workflows/release/install-hub.sh install-hub.sh
RUN ./install-hub.sh

WORKDIR /app
ADD ["package.json", "package-lock.json", "./"]

RUN npm install

ADD . .
RUN npm run build

ENTRYPOINT [ "workflows/release/entrypoint.sh" ]