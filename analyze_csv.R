#!/usr/bin/env Rscript

# Simple R script to read CSV and print column names using data.table
# Reads the downloaded CSV file and displays column information

cat("Reading CSV file and extracting column names using data.table...\n")

# Load data.table package
library(data.table)

# Define the file path
csv_file <- "/app/downloads/sample_data.csv"

# Check if file exists
if (!file.exists(csv_file)) {
    cat("Error: CSV file not found at", csv_file, "\n")
    quit(status = 1)
}

# Read the CSV file using data.table
tryCatch({
    # Read just the first few rows to get column names efficiently using fread
    data <- fread(csv_file, nrows = 1, header = TRUE)
    
    # Get column names
    column_names <- names(data)
    
    # Get column types
    column_types <- sapply(data, class)
    
    # Print results
    cat("\n=== CSV FILE ANALYSIS (using data.table) ===\n")
    cat("File:", csv_file, "\n")
    cat("Number of columns:", length(column_names), "\n")
    cat("Number of rows analyzed:", nrow(data), "(header + 1 row)\n\n")
    
    cat("Column information:\n")
    for (i in seq_along(column_names)) {
        cat(sprintf("%2d. %-20s [%s]\n", i, column_names[i], column_types[i]))
    }
    
    cat("\nColumn names as R vector:\n")
    cat("c(", paste0('"', column_names, '"', collapse = ", "), ")\n")
    
    cat("\ndata.table column selection examples:\n")
    cat("# Select first 3 columns:\n")
    cat("dt[, 1:3]\n")
    cat("# Select by name:\n")
    cat("dt[, .(", paste(column_names[1:min(3, length(column_names))], collapse = ", "), ")]\n")
    
}, error = function(e) {
    cat("Error reading CSV file with data.table:", e$message, "\n")
    quit(status = 1)
})

cat("\nR script completed successfully using data.table!\n")