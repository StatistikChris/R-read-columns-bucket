#!/usr/bin/env Rscript

# Load required libraries
suppressMessages({
  library(data.table)
  library(googleCloudStorageR)
  library(jsonlite)
})

# More efficient function to read only CSV headers from GCS
read_csv_columns_efficient <- function(bucket_name, file_path) {
  tryCatch({
    # Authenticate with GCS
    gcs_auth()
    
    # Set the bucket
    gcs_global_bucket(bucket_name)
    
    # Read only the first chunk of the file to get headers
    # This is much more efficient than downloading the entire file
    chunk_size <- 8192  # Read first 8KB which should contain headers
    
    # Get object metadata first to check if file exists
    obj_meta <- gcs_get_object(file_path, meta = TRUE)
    cat("File size:", obj_meta$size, "bytes\n", file = stderr())
    
    # Read only a small portion from the beginning
    header_data <- gcs_get_object(
      file_path, 
      parseFunction = function(x) {
        # Convert raw bytes to character and split into lines
        text_content <- rawToChar(x[1:min(chunk_size, length(x))])
        lines <- strsplit(text_content, "\n")[[1]]
        
        # Return first two lines (header + one data row for type inference)
        return(lines[1:min(2, length(lines))])
      }
    )
    
    if (length(header_data) == 0 || nchar(header_data[1]) == 0) {
      stop("File appears to be empty or unreadable")
    }
    
    # Parse the header using data.table
    # Create a minimal CSV content with just the header
    csv_text <- paste(header_data, collapse = "\n")
    
    # Use fread to parse just the header
    dt <- fread(text = csv_text, nrows = 0)
    
    # Return column names as JSON
    column_names <- names(dt)
    result <- list(
      success = TRUE,
      columns = column_names,
      column_count = length(column_names),
      file_info = list(
        size_bytes = as.numeric(obj_meta$size),
        updated = obj_meta$updated
      )
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

# Function to read CSV from GCS and return column names (fallback method)
read_csv_columns <- function(bucket_name, file_path) {
  # Try the efficient method first
  tryCatch({
    return(read_csv_columns_efficient(bucket_name, file_path))
  }, error = function(e) {
    cat("Efficient method failed, trying fallback method\n", file = stderr())
    cat("Error was:", e$message, "\n", file = stderr())
  })
  
  # Fallback to downloading the file if the efficient method fails
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
      column_count = length(column_names),
      method = "fallback_download"
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