FROM node:14

WORKDIR /app
COPY package*.json /app
RUN npm install
COPY *.js /app

CMD [ "node", "server.js" ]