ARG NODE_BASE_IMAGE=${NODE_BASE_IMAGE:-node:8.12.0-stretch}
ARG BASE_IMAGE=${BASE_IMAGE:-node:8.12.0-alpine}

FROM $NODE_BASE_IMAGE as build
WORKDIR /code
COPY package.json /code
RUN npm install --production
COPY app.js /code

FROM $BASE_IMAGE
LABEL maintainer peter.rossbach@bee42.com
WORKDIR /code
COPY --from=build /code /code
CMD ["node", "app.js"]
