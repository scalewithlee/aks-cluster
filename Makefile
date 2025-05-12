.PHONY: init plan apply destroy bootstrap get-credentials acr-login deploy-app

# Variables
ENV ?= dev

# Terraform commands
init:
	cd infrastructure/terraform/environments/$(ENV) && terraform init

plan:
	cd infrastructure/terraform/environments/$(ENV) && terraform plan -out=tfplan

apply:
	cd infrastructure/terraform/environments/$(ENV) && terraform apply tfplan

destroy:
	cd infrastructure/terraform/environments/$(ENV) && terraform destroy

bootstrap:
	chmod +x infrastructure/terraform/bootstrap.sh
	infrastructure/terraform/bootstrap.sh

# Kubernetes commands
get-credentials:
	az aks get-credentials --resource-group $$(cd infrastructure/terraform/environments/$(ENV) && terraform output -raw resource_group_name) --name $$(cd infrastructure/terraform/environments/$(ENV) && terraform output -raw aks_name)

acr-login:
	az acr login --name $$(cd infrastructure/terraform/environments/$(ENV) && terraform output -raw acr_name)

# Application commands
deploy-app:
	cd applications/hash-service && \
	export ACR_LOGIN_SERVER=$$(cd ../../infrastructure/terraform/environments/$(ENV) && terraform output -raw acr_login_server) && \
	make build-push && \
	make deploy
