#!/bin/bash

# Build script for R CSV Column Reader Docker image
# This script helps with local testing and debugging

set -e  # Exit on any error

echo "🏗️  Building R CSV Column Reader Docker Image"
echo "=============================================="

# Configuration
IMAGE_NAME=${1:-"r-csv-reader"}
BUILD_CONTEXT=${2:-"."}
DOCKERFILE=${3:-"Dockerfile"}

echo "📋 Build Configuration:"
echo "   Image name: $IMAGE_NAME"
echo "   Build context: $BUILD_CONTEXT"
echo "   Dockerfile: $DOCKERFILE"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Build the image with build progress
echo "🚀 Starting Docker build..."
echo "⏰ This may take several minutes for the first build..."
echo ""

# Build with proper caching and progress output
docker build \
    --progress=plain \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    -t "$IMAGE_NAME" \
    -f "$DOCKERFILE" \
    "$BUILD_CONTEXT"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build completed successfully!"
    echo ""
    echo "🧪 Testing package installation..."
    
    # Test that R packages are properly installed
    docker run --rm "$IMAGE_NAME" Rscript -e "
        packages <- c('plumber', 'data.table', 'googleCloudStorageR', 'jsonlite');
        missing <- packages[!sapply(packages, requireNamespace, quietly = TRUE)];
        if (length(missing) > 0) {
            cat('❌ Missing packages:', paste(missing, collapse = ', '), '\n');
            quit(status = 1);
        } else {
            cat('✅ All packages are properly installed\n');
        }
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Package verification passed!"
    else
        echo "❌ Package verification failed!"
        echo "   Some R packages may not be properly installed"
    fi
    
    echo ""
    echo "📊 Image information:"
    docker images "$IMAGE_NAME" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    echo ""
    echo "🚀 To run the container:"
    echo "   docker run -p 8080:8080 $IMAGE_NAME"
    echo ""
    echo "🧪 To test with GCS credentials:"
    echo "   docker run -p 8080:8080 \\"
    echo "     -v /path/to/service-account.json:/app/credentials/service-account-key.json \\"
    echo "     $IMAGE_NAME"
    echo ""
    echo "🔍 To run interactively for debugging:"
    echo "   docker run -it --entrypoint /bin/bash $IMAGE_NAME"
    echo ""
    echo "🔍 To check R packages manually:"
    echo "   docker run -it --entrypoint Rscript $IMAGE_NAME -e 'installed.packages()[,c(\"Package\", \"Version\")]'"
else
    echo ""
    echo "❌ Build failed!"
    echo ""
    echo "💡 Troubleshooting tips:"
    echo "   - Check your internet connection for package downloads"
    echo "   - Ensure you have enough disk space"
    echo "   - Try: docker system prune to free up space"
    echo "   - For timeout issues, increase Docker's resource limits"
    echo "   - Check Docker logs: docker logs <container_id>"
    exit 1
fi