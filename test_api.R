#!/usr/bin/env Rscript

# Example usage of the CSV column reader API
# This script demonstrates how to use the API locally or remotely

# Configuration
API_BASE_URL <- Sys.getenv("API_URL", "http://localhost:8080")
BUCKET_NAME <- Sys.getenv("TEST_BUCKET", "your-test-bucket")
FILE_PATH <- Sys.getenv("TEST_FILE", "test-data.csv")

# Load required libraries
suppressMessages({
  library(httr)
  library(jsonlite)
})

cat("Testing CSV Column Reader API\n")
cat("=============================\n\n")

# Test 1: Health check
cat("1. Testing health endpoint...\n")
health_response <- GET(paste0(API_BASE_URL, "/health"))
if (status_code(health_response) == 200) {
  health_data <- fromJSON(content(health_response, "text"))
  cat("✓ Health check passed\n")
  cat("  Status:", health_data$status, "\n")
  cat("  Timestamp:", health_data$timestamp, "\n\n")
} else {
  cat("✗ Health check failed\n")
  cat("  Status code:", status_code(health_response), "\n\n")
}

# Test 2: GET request for column names
cat("2. Testing GET /columns endpoint...\n")
get_url <- paste0(API_BASE_URL, "/columns")
get_response <- GET(get_url, query = list(bucket = BUCKET_NAME, file_path = FILE_PATH))

cat("Request URL:", get_url, "?bucket=", BUCKET_NAME, "&file_path=", FILE_PATH, "\n")
cat("Status code:", status_code(get_response), "\n")

if (status_code(get_response) == 200) {
  get_data <- fromJSON(content(get_response, "text"))
  cat("Response:\n")
  cat(toJSON(get_data, auto_unbox = TRUE, pretty = TRUE), "\n\n")
} else {
  cat("Response body:", content(get_response, "text"), "\n\n")
}

# Test 3: POST request for column names
cat("3. Testing POST /columns endpoint...\n")
post_url <- paste0(API_BASE_URL, "/columns")
post_body <- list(bucket = BUCKET_NAME, file_path = FILE_PATH)

post_response <- POST(
  post_url,
  body = toJSON(post_body, auto_unbox = TRUE),
  content_type("application/json")
)

cat("Request URL:", post_url, "\n")
cat("Request body:", toJSON(post_body, auto_unbox = TRUE), "\n")
cat("Status code:", status_code(post_response), "\n")

if (status_code(post_response) == 200) {
  post_data <- fromJSON(content(post_response, "text"))
  cat("Response:\n")
  cat(toJSON(post_data, auto_unbox = TRUE, pretty = TRUE), "\n\n")
} else {
  cat("Response body:", content(post_response, "text"), "\n\n")
}

# Test 4: Error handling (missing parameters)
cat("4. Testing error handling (missing bucket parameter)...\n")
error_response <- GET(paste0(API_BASE_URL, "/columns"), query = list(file_path = FILE_PATH))

cat("Status code:", status_code(error_response), "\n")
if (status_code(error_response) == 200) {
  error_data <- fromJSON(content(error_response, "text"))
  cat("Response:\n")
  cat(toJSON(error_data, auto_unbox = TRUE, pretty = TRUE), "\n\n")
}

cat("Testing completed!\n")
cat("\nUsage examples:\n")
cat("===============\n")
cat("# Set environment variables:\n")
cat("export API_URL='https://your-cloud-run-url'\n")
cat("export TEST_BUCKET='your-gcs-bucket'\n")
cat("export TEST_FILE='path/to/your/file.csv'\n\n")
cat("# Run the test:\n")
cat("Rscript test_api.R\n\n")
cat("# Or test with curl:\n")
cat("curl \"$API_URL/columns?bucket=$TEST_BUCKET&file_path=$TEST_FILE\"\n")