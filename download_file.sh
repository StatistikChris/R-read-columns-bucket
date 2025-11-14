#!/bin/bash

# Download script for Google Cloud Storage file via HTTPS
# This script downloads the specified CSV file from GCS public URL to local storage

set -e  # Exit on any error

# Define variables
FILE_URL="https://storage.googleapis.com/keine_panik_bucket/2025-11-14T10%3A21%3A02.812-05%3A00_sample_data.csv"
LOCAL_PATH="/app/downloads/sample_data.csv"

echo "Starting download from Google Cloud Storage via HTTPS..."
echo "Source: $FILE_URL"
echo "Destination: $LOCAL_PATH"

# Create downloads directory if it doesn't exist
mkdir -p /app/downloads

# Download the file using curl
echo "Downloading file..."
curl -L -o "$LOCAL_PATH" "$FILE_URL"

# Check if curl command was successful
if [ $? -ne 0 ]; then
    echo "Error: Download failed using curl"
    exit 1
fi

# Verify the download
if [ -f "$LOCAL_PATH" ]; then
    echo "Download completed successfully!"
    echo "File saved to: $LOCAL_PATH"
    
    # Check file size
    FILE_SIZE=$(stat -c%s "$LOCAL_PATH" 2>/dev/null || stat -f%z "$LOCAL_PATH" 2>/dev/null || echo "unknown")
    echo "File size: $FILE_SIZE bytes"
    
    # Show first few lines if it's a text file
    echo "First few lines of the file:"
    head -5 "$LOCAL_PATH" 2>/dev/null || echo "Could not read file contents (might be binary)"
else
    echo "Error: Download failed - file not found at $LOCAL_PATH"
    exit 1
fi

echo "Download script completed successfully."