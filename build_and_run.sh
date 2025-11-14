#!/bin/bash

# Build and run example for the GCS file downloader Docker image

set -e

echo "Building the Docker image..."
docker build -t gcs-file-downloader .

echo "Docker image built successfully!"
echo ""
echo "To run the container, you'll need to provide Google Cloud credentials."
echo "Here are the available options:"
echo ""
echo "1. Using service account key file:"
echo "   docker run -v /path/to/key.json:/app/key.json \\"
echo "              -e GOOGLE_APPLICATION_CREDENTIALS=/app/key.json \\"
echo "              -v \$(pwd)/downloads:/app/downloads \\"
echo "              gcs-file-downloader"
echo ""
echo "2. Using existing gcloud auth:"
echo "   docker run -v ~/.config/gcloud:/root/.config/gcloud:ro \\"
echo "              -v \$(pwd)/downloads:/app/downloads \\"
echo "              gcs-file-downloader"
echo ""
echo "3. Interactive mode for authentication:"
echo "   docker run -it -v \$(pwd)/downloads:/app/downloads gcs-file-downloader bash"
echo ""
echo "The downloaded file will be saved to ./downloads/sample_data.csv"

# Create downloads directory if it doesn't exist
mkdir -p downloads