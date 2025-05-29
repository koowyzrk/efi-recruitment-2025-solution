# setting the base image
FROM node:16-alpine

# setting the dir where container will store copied files
WORKDIR /usr/local/weather_app_backend 

# intalling all crucial packages for the app in build-time
COPY package.json package-lock.json ./
RUN npm install

# setting the port that will be exposed
EXPOSE 9000

# setting the enviormental variable to weather-api
ENV APPID 5aeda305c5901cdfac613b050399dfe1

# setup user so the container don't run as root
RUN adduser -S app
USER app

COPY ./src/ ./src/

# command from the package.json start script
CMD ["node","src/index.js"]
