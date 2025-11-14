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
    libfontconfig1-dev \
    libcairo2-dev \
    libxt-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff5-dev \
    libv8-dev \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy package installation script
COPY install_packages.R /tmp/install_packages.R

# Install R packages using the dedicated script
RUN Rscript /tmp/install_packages.R && rm /tmp/install_packages.R

# Create credentials directory
RUN mkdir -p /app/credentials

# Copy R scripts
COPY *.R /app/

# Make R scripts executable
RUN chmod +x /app/*.R

# Run debug script to verify installation
RUN echo "=== Running post-install verification ===" && \
    Rscript /app/debug.R

# Expose the port that the app runs on
EXPOSE 8080

# Set environment variables
ENV PORT=8080

# Command to run the application
CMD ["Rscript", "server.R"]