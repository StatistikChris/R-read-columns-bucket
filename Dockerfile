# Use lightweight Alpine Linux as base
FROM alpine:latest

# Install curl, bash, netcat, socat, and R
RUN apk add --no-cache curl bash netcat-openbsd socat ca-certificates R R-dev

# Install data.table package
RUN Rscript -e "install.packages('data.table', repos='https://cloud.r-project.org/')"

# Create a directory for downloaded files
RUN mkdir -p /app/downloads

# Copy the scripts
COPY download_file.sh /app/download_file.sh
COPY server.sh /app/server.sh

# Make the scripts executable
RUN chmod +x /app/download_file.sh /app/server.sh

# Set the working directory
WORKDIR /app

# Expose port 8080 (required by Cloud Run)
EXPOSE 8080

# Set the default command to run our server (Cloud Run requirement)
CMD ["/app/server.sh"]