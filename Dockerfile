# Use the official Google Cloud SDK image as base
FROM google/cloud-sdk:alpine

# Install bash (in case it's not available)
RUN apk add --no-cache bash

# Create a directory for downloaded files
RUN mkdir -p /app/downloads

# Copy the download script
COPY download_file.sh /app/download_file.sh

# Make the script executable
RUN chmod +x /app/download_file.sh

# Set the working directory
WORKDIR /app

# Set the default command to run our download script
CMD ["/app/download_file.sh"]