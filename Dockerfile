# Use lightweight Alpine Linux as base
FROM alpine:latest

# Install curl, bash, netcat, and R
RUN apk add --no-cache curl bash netcat-openbsd ca-certificates R

# Create a directory for downloaded files
RUN mkdir -p /app/downloads

# Copy the scripts
COPY download_file.sh /app/download_file.sh
COPY server.sh /app/server.sh
COPY analyze_csv.R /app/analyze_csv.R
COPY run_r_analysis.sh /app/run_r_analysis.sh

# Make the scripts executable
RUN chmod +x /app/download_file.sh /app/server.sh /app/analyze_csv.R /app/run_r_analysis.sh

# Set the working directory
WORKDIR /app

# Expose port 8080 (required by Cloud Run)
EXPOSE 8080

# Set the default command to run our server (Cloud Run requirement)
CMD ["/app/server.sh"]