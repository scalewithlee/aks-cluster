.PHONY: build build-local build-push deploy-all login tag push deploy deploy-local get-service

# Variables
IMAGE_NAME ?= hash-service
ACR_LOGIN_SERVER ?= yourloginserver.azurecr.io
IMAGE_TAG ?= latest

# Docker commands
build-local:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# multiarch support
build:
	docker buildx create --use --name multi-platform-builder || true
	docker buildx inspect --bootstrap
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE_NAME):$(IMAGE_TAG) --load .

# ACR commands
login:
	az acr login --name $(shell echo $(ACR_LOGIN_SERVER) | cut -d'.' -f1)

tag:
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(ACR_LOGIN_SERVER)/$(IMAGE_NAME):$(IMAGE_TAG)

# Build and push multi-architecture image directly to ACR
build-push:
	docker buildx create --use --name multi-platform-builder || true
	docker buildx inspect --bootstrap
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t $(ACR_LOGIN_SERVER)/$(IMAGE_NAME):$(IMAGE_TAG) \
		--push .

push: tag
	docker push $(ACR_LOGIN_SERVER)/$(IMAGE_NAME):$(IMAGE_TAG)

# Local Kubernetes deployment
deploy-local:
	kubectl apply -f kubernetes/

# Combined build, push, and deploy
deploy-all: build-push deploy

# Replace ACR placeholder in deployment file and deploy
deploy:
	sed "s/\$${ACR_LOGIN_SERVER}/$(ACR_LOGIN_SERVER)/g" kubernetes/deployment.yaml | kubectl apply -f -
	kubectl apply -f kubernetes/service.yaml

# Get service info
get-service:
	kubectl get service hash-service -o wide
