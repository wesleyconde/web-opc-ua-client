FROM node:23-bookworm

RUN apt-get update && apt-get install dialog

# Create a directory for the server
WORKDIR /app

COPY . .

RUN npm install && npm install opcua-commander -g

# Start a bash shell by default
CMD ["node", "server.js"]