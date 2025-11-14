# Use the official R base image with Ubuntu
FROM r-base:4.3.2

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libssh2-1-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff5-dev \
    && rm -rf /var/lib/apt/lists/*

# Install required R packages
RUN R -e "install.packages(c('plumber', 'data.table', 'jsonlite', 'httr', 'googleCloudStorageR'), repos='https://cran.rstudio.com/', dependencies=TRUE)"

# Create credentials directory
RUN mkdir -p /app/credentials

# Copy R scripts
COPY *.R /app/

# Make R scripts executable
RUN chmod +x /app/*.R

# Expose the port that the app runs on
EXPOSE 8080

# Set environment variables
ENV PORT=8080

# Command to run the application
CMD ["Rscript", "server.R"]