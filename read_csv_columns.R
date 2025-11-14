#!/usr/bin/env Rscript

# Load required libraries
suppressMessages({
  library(data.table)
  library(googleCloudStorageR)
  library(jsonlite)
})

# Function to read CSV from GCS and return column names
read_csv_columns <- function(bucket_name, file_path) {
  tryCatch({
    # Authenticate with GCS (will use service account key or default credentials)
    gcs_auth()
    
    # Set the bucket
    gcs_global_bucket(bucket_name)
    
    # Download the CSV file to a temporary location
    temp_file <- tempfile(fileext = ".csv")
    gcs_get_object(file_path, saveToDisk = temp_file)
    
    # Read the CSV using data.table
    dt <- fread(temp_file, nrows = 0)  # Read only header to get column names
    
    # Clean up temporary file
    unlink(temp_file)
    
    # Return column names as JSON
    column_names <- names(dt)
    result <- list(
      success = TRUE,
      columns = column_names,
      column_count = length(column_names)
    )
    
    return(toJSON(result, auto_unbox = TRUE, pretty = TRUE))
    
  }, error = function(e) {
    # Return error information as JSON
    error_result <- list(
      success = FALSE,
      error = paste("Error:", e$message),
      columns = NULL,
      column_count = 0
    )
    
    return(toJSON(error_result, auto_unbox = TRUE, pretty = TRUE))
  })
}

# Check if script is run with command line arguments
if (length(commandArgs(trailingOnly = TRUE)) >= 2) {
  args <- commandArgs(trailingOnly = TRUE)
  bucket_name <- args[1]
  file_path <- args[2]
  
  cat("Processing file:", file_path, "from bucket:", bucket_name, "\n", file = stderr())
  result <- read_csv_columns(bucket_name, file_path)
  cat(result)
} else {
  cat("Usage: Rscript read_csv_columns.R <bucket_name> <file_path>\n", file = stderr())
  quit(status = 1)
}