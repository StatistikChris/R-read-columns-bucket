# File Download Service for Google Cloud Run

This Docker image downloads a CSV file from Google Cloud Storage via HTTPS and serves a web interface on Google Cloud Run.

## Features

- Downloads file from public GCS URL using curl (no authentication required)
- Serves a web interface showing download status and file information
- Optimized for Google Cloud Run deployment
- Automatic deployment via GitHub Actions

## Files

- `Dockerfile`: Lightweight Alpine-based image with curl, bash, and netcat
- `download_file.sh`: Bash script that downloads the file via HTTPS
- `server.sh`: Pure bash HTTP server for Cloud Run
- `cloud-run-service.yaml`: Cloud Run service configuration
- `.github/workflows/deploy.yml`: GitHub Actions deployment workflow

## What it Downloads

- **Source**: `https://storage.googleapis.com/keine_panik_bucket/2025-11-14T10%3A21%3A02.812-05%3A00_sample_data.csv`
- **Local Path**: `/app/downloads/sample_data.csv`

## Local Testing

### Build and run locally:

```bash
docker build -t file-downloader .
docker run -p 8080:8080 file-downloader
```

Then visit `http://localhost:8080` to see the web interface.

## Google Cloud Run Deployment

### Option 1: Automatic deployment via GitHub Actions

1. **Set up GitHub Secrets** in your repository:
   - `GCP_PROJECT_ID`: Your Google Cloud Project ID
   - `GCP_SA_KEY`: Service account key JSON (base64 encoded)

2. **Push to master/main branch** - deployment happens automatically

### Option 2: Manual deployment

```bash
# Build and push to Google Container Registry
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/file-downloader

# Deploy to Cloud Run
gcloud run deploy file-downloader \
  --image gcr.io/YOUR_PROJECT_ID/file-downloader \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --port 8080
```

## API Endpoints

Once deployed, the service provides:

- **GET /** - Web interface showing file download status and preview
- **GET /health** - JSON health check endpoint

## Requirements

- No authentication required (downloads from public GCS URL)
- Google Cloud Project with Cloud Run API enabled
- For GitHub Actions: Service account with Cloud Run and Container Registry permissions

## Service Configuration

- **Memory**: 512Mi
- **CPU**: 1 vCPU
- **Timeout**: 300 seconds
- **Max Instances**: 10
- **Port**: 8080
- **Public Access**: Enabled (allow unauthenticated)