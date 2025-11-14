#!/usr/bin/env Rscript

# Load plumber
suppressMessages(library(plumber))

# Set authentication for Google Cloud Storage
# The application will use Application Default Credentials (ADC)
Sys.setenv("GOOGLE_APPLICATION_CREDENTIALS" = "/app/credentials/service-account-key.json")

# Create and run the API
pr <- plumb("api.R")

# Get port from environment variable (required for Cloud Run)
port <- as.numeric(Sys.getenv("PORT", "8080"))
host <- "0.0.0.0"

cat("Starting server on", host, "port", port, "\n")

# Run the server
pr$run(host = host, port = port)