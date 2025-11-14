#!/bin/bash

# Simple HTTP server for Cloud Run using only bash and netcat
# Downloads the file on startup and serves a basic web interface

set -e

echo "Starting Cloud Run service..."

# Download the file first
echo "Downloading file on startup..."
/app/download_file.sh

# Get the port from environment variable (Cloud Run provides this)
PORT=${PORT:-8080}

echo "Starting HTTP server on port $PORT..."

# Response functions moved to separate scripts for better modularity and reliability

# More robust HTTP server using socat or nc with proper connection handling
if command -v socat >/dev/null 2>&1; then
    echo "Using socat for more reliable HTTP server..."
    while true; do
        socat TCP-LISTEN:$PORT,fork,reuseaddr EXEC:"/app/handle_request.sh"
    done
else
    echo "Using netcat with improved request handling..."
    while true; do
        {
            # Read HTTP request with timeout
            timeout 30 sh -c '
                read -r request_line
                request_path=$(echo "$request_line" | cut -d" " -f2 | tr -d "\r")
                
                # Skip all headers until empty line
                while read -r line && [ -n "$line" ] && [ "$line" != "$(printf "\r")" ]; do
                    :
                done
                
                # Route requests
                case "$request_path" in
                    "/health")
                        /app/create_health_response.sh
                        ;;
                    *)
                        /app/create_main_response.sh
                        ;;
                esac
            '
        } | nc -l -p "$PORT" -q 1
        
        # Small delay to prevent busy loop
        sleep 0.1
    done
fi