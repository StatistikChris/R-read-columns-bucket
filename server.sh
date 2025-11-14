#!/bin/bash

# Simple HTTP server - returns just column names
set -e

echo "Starting service..."

# Download the file first
echo "Downloading file..."
/app/download_file.sh

PORT=${PORT:-8080}

echo "Starting HTTP server on port $PORT..."

# Simple server that just returns column names
while true; do
    {
        # Read and ignore HTTP request
        while read -r line && [ -n "$line" ] && [ "$line" != "$(printf '\r')" ]; do
            :
        done
        
        # Get column names and return them

        column_names=$(Rscript -e "
            library(data.table)
            data <- fread('/app/downloads/sample_data.csv', nrows = 0, header = TRUE)
            cat(paste(names(data), collapse = ', '))
        " 2>/dev/null)
        
        echo "$column_names"
        
    } | nc -l -p "$PORT" -q 1
    sleep 0.1
done