FROM node:latest

RUN apt-get update && apt-get install -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json .

RUN npm i && npm i -g coffeescript

COPY . .

EXPOSE 7860

CMD ["coffee", "main.coffee"]
