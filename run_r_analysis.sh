#!/bin/bash

# Standalone script to run R analysis on the downloaded CSV file

set -e

echo "Running R column analysis..."

CSV_FILE="/app/downloads/sample_data.csv"

echo "Analyzing CSV file with R..."
echo "=========================="

Rscript /app/analyze_csv.R