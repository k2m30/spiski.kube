FROM node:14-alpine

WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY *.js /app/
COPY views/ /app/views/

CMD [ "node", "server.js" ]