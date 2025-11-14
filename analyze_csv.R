#!/usr/bin/env Rscript

# Simple R script to read CSV and print column names
# Reads the downloaded CSV file and displays column information

cat("Reading CSV file and extracting column names...\n")

# Define the file path
csv_file <- "/app/downloads/sample_data.csv"

# Check if file exists
if (!file.exists(csv_file)) {
    cat("Error: CSV file not found at", csv_file, "\n")
    quit(status = 1)
}

# Read the CSV file
tryCatch({
    # Read just the first few rows to get column names efficiently
    data <- read.csv(csv_file, nrows = 1, header = TRUE)
    
    # Get column names
    column_names <- colnames(data)
    
    # Print results
    cat("\n=== CSV FILE ANALYSIS ===\n")
    cat("File:", csv_file, "\n")
    cat("Number of columns:", length(column_names), "\n\n")
    
    cat("Column names:\n")
    for (i in seq_along(column_names)) {
        cat(sprintf("%2d. %s\n", i, column_names[i]))
    }
    
    cat("\nColumn names as R vector:\n")
    cat("c(", paste0('"', column_names, '"', collapse = ", "), ")\n")
    
}, error = function(e) {
    cat("Error reading CSV file:", e$message, "\n")
    quit(status = 1)
})

cat("\nR script completed successfully!\n")