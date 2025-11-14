#!/bin/bash

# Download script for Google Cloud Storage file via HTTPS
# This script downloads the specified CSV file from GCS public URL to local storage

set -e  # Exit on any error

# Define variables
FILE_URL="https://storage.googleapis.com/keine_panik_bucket/2025-11-14T10%3A21%3A02.812-05%3A00_sample_data.csv"
LOCAL_PATH="/app/downloads/sample_data.csv"

# Create downloads directory if it doesn't exist
mkdir -p /app/downloads

# Download the file using curl
echo "Downloading file..."
curl -L -o "$LOCAL_PATH" "$FILE_URL"

echo "Download script completed."