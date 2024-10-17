SERVICE_NAME = demo
WORKSPACE := $(shell terraform workspace show)
DB_USERNAME := $(SERVICE_NAME)_user
DB_PASSWORD := $(shell openssl rand -base64 32 | tr -d /=+ | cut -c1-30)

.PHPONY: help init plan apply destroy init

help:
	@echo "Usage: make <target>"
	@echo "Targets:"
	@echo "  init        Initialize terraform and create database credentials"
	@echo "  plan        Plan terraform"
	@echo "  apply       Apply terraform"
	@echo "  destroy     Destroy terraform"
	@echo "  credentials Store database credentials in AWS SSM"

plan:
	terraform plan -var-file=environments/$(WORKSPACE).tfvars

apply:
	terraform apply -var-file=environments/${WORKSPACE}.tfvars

destroy:
	terraform destroy -var-file=environments/${WORKSPACE}.tfvars

init:
	terraform init
	@echo "Storing database credentials in AWS SSM"
	@aws ssm put-parameter --name "/$(SERVICE_NAME)/$(WORKSPACE)/db.username" \
	--value "$(DB_USERNAME)" \
	--type "String"
	@aws ssm put-parameter --name "/$(SERVICE_NAME)/$(WORKSPACE)/db.password" \
	--value "$(DB_PASSWORD)" \
	--type "SecureString"
