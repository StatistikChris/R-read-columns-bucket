#!/usr/bin/env Rscript

# R package installation script with comprehensive error checking
# This script ensures all required packages are properly installed

cat("Starting R package installation...\n")

# Set up CRAN mirror
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Required packages
required_packages <- c(
  "plumber",
  "data.table", 
  "jsonlite",
  "googleCloudStorageR"
)

# Function to safely install a package
safe_install <- function(package_name) {
  cat("Installing package:", package_name, "\n")
  
  # Check if already installed
  if (requireNamespace(package_name, quietly = TRUE)) {
    cat("Package", package_name, "is already installed\n")
    return(TRUE)
  }
  
  # Try to install
  tryCatch({
    install.packages(
      package_name, 
      dependencies = TRUE,
      quiet = FALSE,
      verbose = TRUE
    )
    
    # Verify installation
    if (requireNamespace(package_name, quietly = TRUE)) {
      cat("✓ Successfully installed:", package_name, "\n")
      return(TRUE)
    } else {
      cat("✗ Failed to verify installation of:", package_name, "\n")
      return(FALSE)
    }
  }, error = function(e) {
    cat("✗ Error installing", package_name, ":", e$message, "\n")
    return(FALSE)
  })
}

# Install all packages
failed_packages <- c()
for (pkg in required_packages) {
  if (!safe_install(pkg)) {
    failed_packages <- c(failed_packages, pkg)
  }
}

# Final verification
cat("\n=== Installation Summary ===\n")
for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat("✓", pkg, "- OK\n")
  } else {
    cat("✗", pkg, "- FAILED\n")
  }
}

# Exit with error if any packages failed
if (length(failed_packages) > 0) {
  cat("\nFailed to install packages:", paste(failed_packages, collapse = ", "), "\n")
  quit(status = 1)
} else {
  cat("\n✓ All packages installed successfully!\n")
  quit(status = 0)
}