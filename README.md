# R CSV Column Reader API

A Docker-based API service that reads CSV files from Google Cloud Storage and returns column names using R's `data.table` package.

## Features

- 📊 Read CSV files from Google Cloud Storage buckets
- 🔍 Return column names and count as JSON
- 🚀 RESTful API with GET and POST endpoints
- 🐳 Containerized with Docker for easy deployment
- ☁️ Ready for Google Cloud Run deployment

## API Endpoints

### Health Check
```
GET /health
```
Returns the service health status.

### Get Column Names (GET)
```
GET /columns?bucket=<bucket_name>&file_path=<file_path>
```

**Parameters:**
- `bucket`: Google Cloud Storage bucket name
- `file_path`: Path to the CSV file in the bucket (including filename)

**Example:**
```bash
curl "http://localhost:8080/columns?bucket=my-data-bucket&file_path=data/sample.csv"
```

### Get Column Names (POST)
```
POST /columns
Content-Type: application/json

{
  "bucket": "my-data-bucket",
  "file_path": "data/sample.csv"
}
```

**Example:**
```bash
curl -X POST http://localhost:8080/columns \
  -H "Content-Type: application/json" \
  -d '{"bucket":"my-data-bucket","file_path":"data/sample.csv"}'
```

## Response Format

```json
{
  "success": true,
  "columns": ["col1", "col2", "col3"],
  "column_count": 3
}
```

In case of error:
```json
{
  "success": false,
  "error": "Error message",
  "columns": null,
  "column_count": 0
}
```

## Local Development

### Prerequisites
- Docker installed on your machine
- Google Cloud Storage bucket with CSV files
- Service account key with Storage Object Viewer permissions

### Build and Run

1. **Build the Docker image (recommended method):**
   ```bash
   # Use the provided build script for better error handling
   ./build.sh
   ```

2. **Or build manually:**
   ```bash
   docker build -t r-csv-reader .
   ```

3. **Run the container:**
   ```bash
   # Option 1: Using service account key file
   docker run -p 8080:8080 \
     -v /path/to/your/service-account-key.json:/app/credentials/service-account-key.json \
     r-csv-reader

   # Option 2: Using Application Default Credentials (if running on GCP)
   docker run -p 8080:8080 r-csv-reader
   ```

4. **Test the API:**
   ```bash
   curl "http://localhost:8080/columns?bucket=your-bucket&file_path=your-file.csv"
   ```

## Google Cloud Run Deployment

### Prerequisites
- Google Cloud Project with billing enabled
- Cloud Run API enabled
- Artifact Registry API enabled (or Container Registry)
- Service account with Storage Object Viewer permissions

### Deployment Steps

1. **Set up environment variables:**
   ```bash
   export PROJECT_ID="your-project-id"
   export SERVICE_NAME="csv-column-reader"
   export REGION="us-central1"
   export REPOSITORY_NAME="r-apps"
   ```

2. **Create Artifact Registry repository (if not exists):**
   ```bash
   gcloud artifacts repositories create $REPOSITORY_NAME \
     --repository-format=docker \
     --location=$REGION \
     --project=$PROJECT_ID
   ```

3. **Configure Docker for Artifact Registry:**
   ```bash
   gcloud auth configure-docker $REGION-docker.pkg.dev
   ```

4. **Build and tag the image:**
   ```bash
   docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$SERVICE_NAME .
   ```

5. **Push the image:**
   ```bash
   docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$SERVICE_NAME
   ```

6. **Deploy to Cloud Run:**
   ```bash
   gcloud run deploy $SERVICE_NAME \
     --image $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$SERVICE_NAME \
     --platform managed \
     --region $REGION \
     --allow-unauthenticated \
     --port 8080 \
     --memory 1Gi \
     --cpu 1 \
     --max-instances 10 \
     --project $PROJECT_ID
   ```

### GitHub Actions Deployment (Recommended)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Cloud Run

on:
  push:
    branches: [ main ]

env:
  PROJECT_ID: your-project-id
  SERVICE_NAME: csv-column-reader
  REGION: us-central1

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Setup Cloud SDK
      uses: google-github-actions/setup-gcloud@v1
      with:
        project_id: ${{ env.PROJECT_ID }}
        service_account_key: ${{ secrets.GCP_SA_KEY }}
        export_default_credentials: true

    - name: Configure Docker
      run: gcloud auth configure-docker ${{ env.REGION }}-docker.pkg.dev

    - name: Build and Push
      run: |
        docker build -t ${{ env.REGION }}-docker.pkg.dev/${{ env.PROJECT_ID }}/r-apps/${{ env.SERVICE_NAME }} .
        docker push ${{ env.REGION }}-docker.pkg.dev/${{ env.PROJECT_ID }}/r-apps/${{ env.SERVICE_NAME }}

    - name: Deploy to Cloud Run
      run: |
        gcloud run deploy ${{ env.SERVICE_NAME }} \
          --image ${{ env.REGION }}-docker.pkg.dev/${{ env.PROJECT_ID }}/r-apps/${{ env.SERVICE_NAME }} \
          --platform managed \
          --region ${{ env.REGION }} \
          --allow-unauthenticated \
          --port 8080
```

### Authentication Setup

For production deployment, the service will use the default service account attached to the Cloud Run service. Make sure this service account has the following IAM roles:

- `Storage Object Viewer` - to read files from Cloud Storage

You can set this up with:
```bash
# Get the default compute service account
SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:Compute Engine default service account" --format="value(email)")

# Grant Storage Object Viewer role
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/storage.objectViewer"
```

## Usage Examples

### Example 1: Reading a simple CSV
```bash
curl "https://your-service-url/columns?bucket=my-data&file_path=customers.csv"
```

Response:
```json
{
  "success": true,
  "columns": ["id", "name", "email", "created_at"],
  "column_count": 4
}
```

### Example 2: Reading from a subdirectory
```bash
curl "https://your-service-url/columns?bucket=analytics-data&file_path=2024/january/sales.csv"
```

### Example 3: Using POST for complex paths
```bash
curl -X POST https://your-service-url/columns \
  -H "Content-Type: application/json" \
  -d '{
    "bucket": "data-warehouse",
    "file_path": "exports/very-long-filename-with-special-chars.csv"
  }'
```

## Troubleshooting

### Common Issues

1. **Build timeout errors ("context deadline exceeded"):**
   - Use the provided `build.sh` script for local testing
   - Increase Cloud Build timeout in `cloudbuild.yaml`
   - Use a more powerful machine type (E2_HIGHCPU_8) for building
   - Enable Docker BuildKit for faster builds: `export DOCKER_BUILDKIT=1`

2. **Authentication errors:**
   - Ensure service account has proper permissions
   - Check that credentials are properly mounted in Docker

3. **File not found:**
   - Verify bucket name and file path
   - Check that the service account can access the bucket

4. **Memory issues:**
   - Large CSV files might require more memory
   - Increase Cloud Run memory allocation if needed

5. **Slow CSV processing:**
   - The app now uses efficient header-only reading
   - For very large files, only the first 8KB is read to get column names

### Logs
View logs in Cloud Run:
```bash
gcloud logs tail --follow --project=$PROJECT_ID
```

## Architecture

The application consists of:

- **`read_csv_columns.R`**: Core logic for reading CSV from GCS
- **`api.R`**: Plumber API endpoints definition  
- **`server.R`**: Main server script
- **`Dockerfile`**: Container configuration

## Dependencies

- **R packages:**
  - `plumber`: Web framework
  - `data.table`: Fast CSV reading
  - `googleCloudStorageR`: GCS integration
  - `jsonlite`: JSON handling

## License

This project is open source and available under the MIT License.