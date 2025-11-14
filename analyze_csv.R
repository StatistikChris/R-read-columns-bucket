#!/usr/bin/env Rscript

# Simple R script to read CSV and print column names using data.table
# Reads the downloaded CSV file and displays column information

cat("Reading CSV file and extracting column names using data.table...\n")

# Load data.table package
library(data.table)

# Define the file path
csv_file <- "/app/downloads/sample_data.csv"

# Read the CSV file using data.table

# Read just the first few rows to get column names efficiently using fread
data <- fread(csv_file, nrows = 1, header = TRUE)
    
# Get column names
cat(names(data), sep = "\n")

    

cat("\nR script completed successfully using data.table!\n")