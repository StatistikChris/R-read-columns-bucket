#!/bin/bash

# Create health check JSON response

file_path="/app/downloads/sample_data.csv"
file_exists="false"
file_size="0"

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