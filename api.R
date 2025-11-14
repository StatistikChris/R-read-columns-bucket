#!/usr/bin/env Rscript

# Load required libraries
suppressMessages({
  library(plumber)
  library(data.table)
  library(googleCloudStorageR)
  library(jsonlite)
})

# Source the CSV reading function
source("read_csv_columns.R")

#* @apiTitle CSV Column Reader API
#* @apiDescription API to read CSV files from Google Cloud Storage and return column names

#* Health check endpoint
#* @get /health
function() {
  list(status = "healthy", timestamp = Sys.time())
}

#* Get column names from CSV file in Google Cloud Storage
#* @param bucket The name of the Google Cloud Storage bucket
#* @param file_path The path to the CSV file in the bucket (including filename)
#* @get /columns
function(bucket, file_path) {
  # Validate parameters
  if (is.null(bucket) || bucket == "") {
    res <- list(
      success = FALSE,
      error = "Missing required parameter: bucket",
      columns = NULL,
      column_count = 0
    )
    return(res)
  }
  
  if (is.null(file_path) || file_path == "") {
    res <- list(
      success = FALSE,
      error = "Missing required parameter: file_path",
      columns = NULL,
      column_count = 0
    )
    return(res)
  }
  
  # Call the CSV reading function
  result_json <- read_csv_columns(bucket, file_path)
  
  # Parse JSON back to list for proper API response
  result <- fromJSON(result_json)
  return(result)
}

#* Get column names from CSV file in Google Cloud Storage (POST method for larger parameters)
#* @param bucket The name of the Google Cloud Storage bucket
#* @param file_path The path to the CSV file in the bucket (including filename)
#* @post /columns
function(req) {
  body <- req$body
  
  # Handle JSON body
  if (is.character(body)) {
    body <- fromJSON(body)
  }
  
  bucket <- body$bucket
  file_path <- body$file_path
  
  # Validate parameters
  if (is.null(bucket) || bucket == "") {
    res <- list(
      success = FALSE,
      error = "Missing required parameter: bucket",
      columns = NULL,
      column_count = 0
    )
    return(res)
  }
  
  if (is.null(file_path) || file_path == "") {
    res <- list(
      success = FALSE,
      error = "Missing required parameter: file_path",
      columns = NULL,
      column_count = 0
    )
    return(res)
  }
  
  # Call the CSV reading function
  result_json <- read_csv_columns(bucket, file_path)
  
  # Parse JSON back to list for proper API response
  result <- fromJSON(result_json)
  return(result)
}