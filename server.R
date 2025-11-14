#!/usr/bin/env Rscript

# Verify all required packages are available before starting
cat("Verifying required packages...\n")

required_packages <- c("plumber", "data.table", "googleCloudStorageR", "jsonlite")
missing_packages <- c()

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    missing_packages <- c(missing_packages, pkg)
    cat("✗ Missing package:", pkg, "\n")
  } else {
    cat("✓ Package available:", pkg, "\n")
  }
}

if (length(missing_packages) > 0) {
  cat("ERROR: Missing required packages:", paste(missing_packages, collapse = ", "), "\n")
  cat("Please rebuild the Docker image to install missing packages.\n")
  quit(status = 1)
}

# Load required libraries
cat("Loading libraries...\n")
suppressMessages({
  library(plumber)
  library(data.table)
  library(googleCloudStorageR)
  library(jsonlite)
})

cat("All packages loaded successfully!\n")

# Set authentication for Google Cloud Storage
# The application will use Application Default Credentials (ADC)
if (file.exists("/app/credentials/service-account-key.json")) {
  Sys.setenv("GOOGLE_APPLICATION_CREDENTIALS" = "/app/credentials/service-account-key.json")
  cat("Using service account credentials\n")
} else {
  cat("Using Application Default Credentials\n")
}

# Create and run the API
cat("Loading API definitions...\n")
pr <- plumb("api.R")

# Get port from environment variable (required for Cloud Run)
port <- as.numeric(Sys.getenv("PORT", "8080"))
host <- "0.0.0.0"

cat("Starting server on", host, "port", port, "\n")
cat("Health check available at: http://", host, ":", port, "/health\n", sep = "")
cat("API endpoint available at: http://", host, ":", port, "/columns\n", sep = "")

# Run the server
pr$run(host = host, port = port)