# hash-service

A simple Go microservice that provides various hash functions via a REST API.

## Features

- Calculates MD5, SHA1, and SHA256 hashes for input strings
- RESTful API design
- Health check endpoint for Kubernetes probes
- Configurable via environment variables
- Optimized Docker container

## API Endpoints

- `/` - Shows usage information and documentation
- `/md5/{string}` - Calculates the MD5 hash of the provided string
- `/sha1/{string}` - Calculates the SHA1 hash of the provided string
- `/sha256/{string}` - Calculates the SHA256 hash of the provided string
- `/health` - Health check endpoint, returns "OK" if the service is running

## Development

### Prerequisites

- Go 1.21 or later
- Docker for building containers
- kubectl for Kubernetes deployment
- Access to an AKS cluster and ACR registry

### Building and Running Locally

#### Using Go

```bash
# Run directly with Go
go run main.go
```

#### Using Docker

```bash
# Build the Docker image
docker build -t hash-service:latest .

# Run the container locally
docker run -p 8080:8080 hash-service:latest
```

### Testing

Test the service locally:

```bash
# Test the API endpoints
curl http://localhost:8080/
curl http://localhost:8080/md5/hello
curl http://localhost:8080/sha1/hello
curl http://localhost:8080/sha256/hello
curl http://localhost:8080/health
```

## Kubernetes Deployment

The application includes Kubernetes manifests in the `kubernetes/` directory:

- `deployment.yaml` - Defines the Kubernetes Deployment
- `service.yaml` - Defines the Kubernetes Service

### Deploying to AKS

The Makefile includes commands to build, push, and deploy the application to AKS using ACR:

```bash
# Set your Azure Container Registry login server
export ACR_LOGIN_SERVER=yourregistry.azurecr.io

# Login to ACR
make login

# Build the Docker image
make build

# Tag and push to ACR
make push

# Deploy to Kubernetes
make deploy

# Get the service external IP
make get-service
```

### Automatic Deployment

If you're using the root project Makefile, you can deploy with a single command:

```bash
# From the project root
make deploy-app
```

This will automatically extract the ACR login server from Terraform outputs, build and push the image, and deploy to AKS.

## Environment Variables

The application supports the following environment variables:

- `PORT` - The port to listen on (default: 8080)

## Monitoring and Observability

- The `/health` endpoint can be used by Kubernetes for liveness and readiness probes
- The deployment includes resource limits and requests for proper scheduling and scaling
- Logs are written to stdout for collection by container logging systems
