#!/usr/bin/env Rscript

# Debug script to check R package installation and environment
cat("=== R Environment Debug Information ===\n")

# R version
cat("R Version:\n")
print(version)
cat("\n")

# Installed packages
cat("Installed Packages:\n")
installed <- installed.packages()
required <- c("plumber", "data.table", "googleCloudStorageR", "jsonlite")

cat("Required packages status:\n")
for (pkg in required) {
  if (pkg %in% installed[, "Package"]) {
    version <- installed[pkg, "Version"]
    cat("✓", pkg, "version", version, "\n")
  } else {
    cat("✗", pkg, "NOT INSTALLED\n")
  }
}

cat("\nAll installed packages:\n")
pkg_info <- installed[, c("Package", "Version")]
print(pkg_info[order(pkg_info[, "Package"]), ])

# Library paths
cat("\nLibrary paths:\n")
print(.libPaths())

# Repository information
cat("\nConfigured repositories:\n")
print(getOption("repos"))

# Try loading each required package
cat("\nTesting package loading:\n")
for (pkg in required) {
  result <- tryCatch({
    library(pkg, character.only = TRUE)
    cat("✓", pkg, "loaded successfully\n")
    TRUE
  }, error = function(e) {
    cat("✗", pkg, "failed to load:", e$message, "\n")
    FALSE
  })
}

# System information
cat("\nSystem Information:\n")
cat("Platform:", R.version$platform, "\n")
cat("OS:", Sys.info()["sysname"], "\n")
cat("Architecture:", Sys.info()["machine"], "\n")

# Environment variables
cat("\nRelevant Environment Variables:\n")
env_vars <- c("R_LIBS", "R_LIBS_USER", "R_LIBS_SITE", "GOOGLE_APPLICATION_CREDENTIALS")
for (var in env_vars) {
  value <- Sys.getenv(var)
  if (value != "") {
    cat(var, "=", value, "\n")
  }
}

cat("\n=== Debug Information Complete ===\n")