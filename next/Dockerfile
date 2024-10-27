FROM node:20.18.0

ENV TZ=Asia/Tokyo

WORKDIR /app

COPY package.json yarn.lock /app/
RUN yarn install

COPY . /app

CMD ["yaen", "dev", "-p", "3000"]
