# AKS Cluster Repository

This repository contains the necessary code to deploy an Azure Kubernetes Service (AKS) cluster using Terraform, along with sample applications to deploy to the cluster.

## Prerequisites

- Azure CLI installed and configured
- Terraform installed (version 1.0 or later)
- Access to an Azure subscription
- kubectl installed (optional, for managing the AKS cluster)

## Getting Started

1. Clone this repository:
```bash
git clone https://github.com/yourusername/aks-cluster.git
cd aks-cluster
```

2. Bootstrap the Terraform backend:
```bash
make bootstrap
```

3. Update the backend.tf file in `infrastructure/terraform/environments/dev` with the values output from the bootstrap command.

4. Initialize Terraform:
```bash
make init
```

5. Plan the deployment:
```bash
make plan
```

6. Apply the deployment:
```bash
make apply
```

7. Configure kubectl to work with your new AKS cluster:
```bash
make get-credentials
```

8. Deploy the hash-service application:
```bash
make deploy-app
```

This will automatically build the application, push it to your Azure Container Registry, and deploy it to your AKS cluster.

## Infrastructure

The Terraform configuration creates the following resources:

- **Resource Group**: Contains all Azure resources for the AKS deployment
- **Virtual Network and Subnet**: Network infrastructure for the AKS cluster
- **Network Security Group with rules**: Controls traffic flow to and from the cluster
- **Azure Container Registry (ACR)**: Private registry for container images
- **AKS Cluster with system and user node pools**: The Kubernetes cluster itself
- **Log Analytics Workspace**: For monitoring cluster performance and health
- **RBAC Role Assignments**: Properly connects AKS to ACR

### Key Differences from EKS

If you're familiar with Amazon EKS, here are the key differences you'll encounter with AKS:

1. **Authentication**:
   - AKS uses Azure Active Directory (AAD) for authentication
   - Azure RBAC integration provides role-based access control

2. **Networking**:
   - AKS uses Azure VNet and subnets instead of VPC
   - The Azure CNI provides networking for pods

3. **Storage**:
   - AKS uses Azure Disk and Azure File storage classes
   - CSI drivers are included by default

4. **Container Registry**:
   - Azure Container Registry (ACR) instead of ECR
   - Integration via Azure RBAC instead of IAM policies
   - No need for docker config secrets for authentication

5. **Monitoring**:
   - Integration with Azure Monitor and Log Analytics Workspace
   - Container Insights provides detailed metrics

6. **Node Management**:
   - System and user node pools separate system workloads from application workloads
   - Auto-scaling is supported per node pool

## Applications

The repository includes a sample Go application called hash-service that can be deployed to the AKS cluster:

- Simple microservice that calculates various hash values (MD5, SHA1, SHA256)
- Includes Kubernetes deployment and service manifests
- Demonstrates basic containerization and Kubernetes deployment patterns
- Showcases integration with the Azure Container Registry

### Adding Your Own Applications

To add your own applications to the repository:

1. Create a new directory in the `applications/` folder:
```bash
mkdir -p applications/your-app/kubernetes
```

2. Include the necessary files:
   - Dockerfile for containerization
   - Application source code
   - Kubernetes manifests (deployment.yaml, service.yaml, etc.)
   - Makefile for build and deployment automation

3. Follow the same pattern as hash-service for image references:
```yaml
# In your deployment.yaml
image: ${ACR_LOGIN_SERVER}/your-app:latest
```

4. Update the root Makefile to include commands for your application:
```makefile
deploy-your-app:
	cd applications/your-app && \
	export ACR_LOGIN_SERVER=$(cd ../../infrastructure/terraform/environments/$(ENV) && terraform output -raw acr_login_server) && \
	make build && \
	make tag && \
	make push && \
	make deploy
```

## Container Registry

The Terraform configuration automatically provisions an Azure Container Registry (ACR) and integrates it with the AKS cluster. This integration uses Azure RBAC to grant the AKS cluster's managed identity the AcrPull role, allowing it to pull images from the registry without additional configuration.

### Features

- **Private Container Registry**: Securely store your container images
- **Automated Integration**: AKS is configured to access ACR via Azure RBAC
- **Configurable SKU**: Choose Basic, Standard, or Premium based on your needs
- **Optional Geo-replication**: For Premium SKU, enable geo-replication for improved performance and availability
- **Support for All Applications**: Works with any containerized application in your cluster

### Using the Container Registry

To build and push images to your ACR:

```bash
# Login to ACR (uses credentials from terraform output)
make acr-login

# Build, tag, push, and deploy an application
make deploy-app

# Or do it step by step
cd applications/hash-service
export ACR_LOGIN_SERVER=$(cd ../../infrastructure/terraform/environments/dev && terraform output -raw acr_login_server)
make build
make tag
make push
make deploy
```

### Custom Applications

The setup is designed to work with any application, not just the included hash-service. For your own applications:

1. Create a similar directory structure in the `applications/` folder
2. Include a Dockerfile and Kubernetes manifests
3. Update the Makefile to handle building and deploying your application
4. Use the same ACR integration pattern

The deployment.yaml files should use `${ACR_LOGIN_SERVER}` as a placeholder:

```yaml
image: ${ACR_LOGIN_SERVER}/your-application:latest
```

This placeholder will be replaced with the actual ACR login server during deployment.

## Clean Up

To destroy all resources created by Terraform:

```bash
make destroy
```
