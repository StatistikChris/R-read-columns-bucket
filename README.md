# Google Cloud Storage File Downloader

This Docker image downloads a specific CSV file from Google Cloud Storage using gsutil and bash.

## Files

- `Dockerfile`: Defines the Docker image based on the official Google Cloud SDK
- `download_file.sh`: Bash script that downloads the file from GCS
- `README.md`: This documentation file

## Building the Docker Image

```bash
docker build -t gcs-file-downloader .
```

## Running the Container

### Option 1: Using Service Account Key File

If you have a service account key file:

```bash
docker run -v /path/to/your/service-account-key.json:/app/key.json \
           -e GOOGLE_APPLICATION_CREDENTIALS=/app/key.json \
           -v /path/to/local/downloads:/app/downloads \
           gcs-file-downloader
```

### Option 2: Using gcloud auth (if already authenticated on host)

```bash
docker run -v ~/.config/gcloud:/root/.config/gcloud:ro \
           -v /path/to/local/downloads:/app/downloads \
           gcs-file-downloader
```

### Option 3: Interactive mode for authentication

```bash
docker run -it \
           -v /path/to/local/downloads:/app/downloads \
           gcs-file-downloader bash
```

Then inside the container:
```bash
gcloud auth login
./download_file.sh
```

## What it Downloads

- **Source**: `gs://keine_panik_bucket/2025-11-14T10:21:02.812-05:00_sample_data.csv`
- **Local Path**: `/app/downloads/sample_data.csv`

## Prerequisites

- Docker installed on your system
- Google Cloud Storage access credentials (service account key or authenticated gcloud)
- Read permissions for the specified GCS bucket and file

## Notes

- The downloaded file will be saved to `/app/downloads/sample_data.csv` inside the container
- Mount a local directory to `/app/downloads` to persist the file on your host system
- The script includes error handling and will show file details after successful download