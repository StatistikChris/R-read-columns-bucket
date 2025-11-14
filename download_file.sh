#!/bin/bash

# Download script for Google Cloud Storage file
# This script downloads the specified CSV file from GCS to local storage

set -e  # Exit on any error

# Define variables
GCS_PATH="gs://keine_panik_bucket/2025-11-14T10:21:02.812-05:00_sample_data.csv"
LOCAL_PATH="/app/downloads/sample_data.csv"

echo "Starting download from Google Cloud Storage..."
echo "Source: $GCS_PATH"
echo "Destination: $LOCAL_PATH"

# Authenticate with Google Cloud (expects credentials to be mounted or configured)
echo "Checking Google Cloud authentication..."
gcloud auth list

# Download the file using gsutil
echo "Downloading file..."
gsutil cp "$GCS_PATH" "$LOCAL_PATH"

# Verify the download
if [ -f "$LOCAL_PATH" ]; then
    echo "Download completed successfully!"
    echo "File saved to: $LOCAL_PATH"
    echo "File size: $(du -h "$LOCAL_PATH" | cut -f1)"
    echo "First few lines of the file:"
    head -5 "$LOCAL_PATH" || echo "Could not read file contents"
else
    echo "Error: Download failed - file not found at $LOCAL_PATH"
    exit 1
fi

echo "Script completed."