FROM node:22-alpine
RUN mkdir -p /app/dist
WORKDIR /app

COPY dist  ./dist
COPY package.json web-server.js ./
ENV NODE_ENV=production

RUN npm install --production

EXPOSE 3000

CMD ["node", "web-server.js"]
