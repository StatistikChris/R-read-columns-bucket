# Use the official R base image with Ubuntu
FROM r-base:4.3.2

# Set the working directory
WORKDIR /app

# Install system dependencies in a single layer with cache cleanup
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libssh2-1-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install R packages with specific versions to improve caching and reduce build time
RUN R -e "options(repos = c(CRAN = 'https://cran.rstudio.com/')); \
    install.packages(c('plumber', 'data.table', 'jsonlite', 'googleCloudStorageR'), \
    dependencies = c('Depends', 'Imports'), \
    Ncpus = parallel::detectCores())"

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