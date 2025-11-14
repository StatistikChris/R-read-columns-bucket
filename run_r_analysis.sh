#!/bin/bash

# Standalone script to run R analysis on the downloaded CSV file

set -e

echo "Running R column analysis..."

CSV_FILE="/app/downloads/sample_data.csv"

if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file not found. Please run the download first."
    echo "Expected file: $CSV_FILE"
    exit 1
fi

if ! command -v Rscript >/dev/null 2>&1; then
    echo "Error: R is not installed"
    exit 1
fi

echo "Analyzing CSV file with R..."
echo "=========================="

Rscript /app/analyze_csv.R