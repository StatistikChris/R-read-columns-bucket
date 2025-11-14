#!/bin/bash

# Build and run the Cloud Run file downloader service locally

set -e

echo "Building the Docker image for Cloud Run..."
docker build -t file-downloader .

echo "Docker image built successfully!"
echo ""
echo "Starting the service locally on port 8080..."
echo "The service will:"
echo "1. Download the file from GCS via HTTPS"
echo "2. Serve a web interface with file information"
echo "3. Provide health check endpoints"
echo ""

echo "Running container..."
docker run -p 8080:8080 file-downloader &

echo ""
echo "Service is starting up..."
echo "Once ready, you can access:"
echo "- Main interface: http://localhost:8080"
echo "- Health check: http://localhost:8080/health"
echo ""
echo "Press Ctrl+C to stop the service"

# Wait for user input to stop
trap 'echo "Stopping service..."; docker stop $(docker ps -q --filter ancestor=file-downloader); exit 0' INT
wait