# Use an official Node.js runtime as a parent image
FROM node:22

# Install cron
RUN apt-get update && apt-get install -y cron
RUN apt-get update && apt-get install -y dos2unix

# Don't run as root
USER node

# Set the working directory in the container
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app
RUN npm install --loglevel verbose

# Copy the current directory contents into the container at /usr/src/app
COPY --chown=node:node . .

# Define environment variable
ENV NODE_ENV=production

# Allow self-signed SSL certs
ENV NODE_TLS_REJECT_UNAUTHORIZED=0

# Create the cache directory
RUN mkdir -p ./cache && chown node:node ./cache

# Copy the crontab file
ADD cron/apply-interest /etc/cron.d/apply-interest

# Use root
USER root

# Change line ending format to LF
RUN dos2unix /etc/cron.d/apply-interest

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/apply-interest

# Apply cron job
RUN crontab /etc/cron.d/apply-interest

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Create the log file to be able to run tail
RUN touch /var/log/hello-cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/hello-cron.log