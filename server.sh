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

# Function to create HTML response
create_response() {
    local file_path="/app/downloads/sample_data.csv"
    local file_exists="false"
    local file_size="0"
    local preview=""
    
    if [ -f "$file_path" ]; then
        file_exists="true"
        file_size=$(stat -c%s "$file_path" 2>/dev/null || stat -f%z "$file_path" 2>/dev/null || echo "0")
        preview=$(head -10 "$file_path" 2>/dev/null | sed 's/</\&lt;/g; s/>/\&gt;/g' || echo "Could not read file")
    fi
    
    # Get R analysis results if available
    local r_analysis=""
    if command -v Rscript >/dev/null 2>&1 && [ -f "$file_path" ]; then
        r_analysis=$(Rscript /app/analyze_csv.R 2>/dev/null | sed 's/</\&lt;/g; s/>/\&gt;/g' || echo "R analysis failed")
    fi
    
    cat << EOF
HTTP/1.1 200 OK
Content-Type: text/html
Connection: close

<!DOCTYPE html>
<html>
<head>
    <title>File Download Service</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .status { padding: 20px; background: #e8f5e8; border-radius: 5px; margin: 20px 0; }
        .info { padding: 15px; background: #f0f8ff; border-radius: 5px; margin: 10px 0; }
        pre { background: #f5f5f5; padding: 10px; border-radius: 3px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>File Download Service</h1>
        <div class="status">
            <h2>✅ Service Status: Running</h2>
            <p>File has been successfully downloaded and saved locally.</p>
        </div>
        
        <div class="info">
            <h3>Downloaded File Information:</h3>
            <ul>
                <li><strong>Source URL:</strong> https://storage.googleapis.com/keine_panik_bucket/2025-11-14T10%3A21%3A02.812-05%3A00_sample_data.csv</li>
                <li><strong>Local Path:</strong> /app/downloads/sample_data.csv</li>
                <li><strong>File Exists:</strong> $file_exists</li>
                <li><strong>File Size:</strong> $file_size bytes</li>
                <li><strong>Current Time:</strong> $(date)</li>
            </ul>
        </div>
        
        <div class="info">
            <h3>R Column Analysis:</h3>
            <pre>$r_analysis</pre>
        </div>
        
        <div class="info">
            <h3>File Preview (first 10 lines):</h3>
            <pre>$preview</pre>
        </div>
        
        <div class="info">
            <h3>Available Endpoints:</h3>
            <ul>
                <li><strong>GET /</strong> - This status page</li>
                <li><strong>GET /health</strong> - Health check endpoint</li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF
}

# Function to create health check response
create_health_response() {
    local file_path="/app/downloads/sample_data.csv"
    local file_exists="false"
    local file_size="0"
    
    if [ -f "$file_path" ]; then
        file_exists="true"
        file_size=$(stat -c%s "$file_path" 2>/dev/null || stat -f%z "$file_path" 2>/dev/null || echo "0")
    fi
    
    cat << EOF
HTTP/1.1 200 OK
Content-Type: application/json
Connection: close

{
    "status": "healthy",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
    "file_exists": $file_exists,
    "file_size": $file_size
}
EOF
}

# Simple HTTP server loop
while true; do
    {
        # Read the HTTP request
        read -r request_line
        request_path=$(echo "$request_line" | cut -d' ' -f2)
        
        # Skip headers
        while read -r header && [ -n "$header" ]; do
            :
        done
        
        # Route requests
        case "$request_path" in
            "/health")
                create_health_response
                ;;
            *)
                create_response
                ;;
        esac
    } | nc -l -p "$PORT"
done