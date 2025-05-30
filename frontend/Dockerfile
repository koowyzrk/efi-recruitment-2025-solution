# setting the base image
FROM node:16-alpine

# setting the dir where container will store copied files
WORKDIR /usr/local/weatherapp_frontend 

# intalling all crucial packages for the app in build-time
COPY package.json package-lock.json ./
# RUN npm install
COPY . .

# setup user so the container don't run as root
# RUN adduser -S app
# USER app

EXPOSE 8000

# command from the package.json start script
# CMD ["node_modules/.bin/webpack-dev-server", "--config" , "webpack.config.js", "--progress", "--inline", "--colors"]
