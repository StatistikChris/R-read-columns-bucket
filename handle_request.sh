#!/bin/bash

# Helper script to handle individual HTTP requests

# Read the request line
read -r request_line
request_path=$(echo "$request_line" | cut -d' ' -f2 | tr -d '\r')

# Skip headers until empty line
while read -r line && [ -n "$line" ] && [ "$line" != "$(printf '\r')" ]; do
    :
done

# Route the request
case "$request_path" in
    "/health")
        /app/create_health_response.sh
        ;;
    *)
        /app/create_main_response.sh
        ;;
esac