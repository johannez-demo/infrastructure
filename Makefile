SERVICE_NAME=demo
REGION=us-west-2
WORKSPACE=$(shell terraform workspace show)


PEM_KEY_PATH = ~/.ssh/$(SERVICE_NAME).pem
EC2_DEV_TAG = $(SERVICE_NAME)-dev-web
DOCROOT=/var/www/html
VENDOR_DIR=$(DOCROOT)/vendor
SCRIPTS_DIR=$(DOCROOT)/scripts
WPCLI=$(VENDOR_DIR)/bin/wp
PUBLIC_IP=$(shell aws ec2 describe-instances --filters "Name=tag:Name,Values=$(EC2_DEV_TAG)" --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

DB_USERNAME=$(shell aws ssm get-parameter --name \
	"/$(SERVICE_NAME)/$(WORKSPACE)/db.username" \
	--with-decryption --query "Parameter.Value" --output text)
DB_PASSWORD=$(shell aws ssm get-parameter --name \
	"/$(SERVICE_NAME)/$(WORKSPACE)/db.password" \
	--with-decryption --query "Parameter.Value" --output text)
WP_ADMIN_USER=$(shell aws ssm get-parameter --name \
	"/$(SERVICE_NAME)/$(WORKSPACE)/wp.username" \
	--with-decryption --query "Parameter.Value" --output text)
WP_ADMIN_PASSWORD=$(shell aws ssm get-parameter --name \
	"/$(SERVICE_NAME)/$(WORKSPACE)/wp.password" \
	--with-decryption --query "Parameter.Value" --output text)

.PHPONY: help init plan apply destroy init

help:
	@echo "Usage: make <target>"
	@echo "Targets:"
	@echo "  init        Initialize terraform and create credentials"
	@echo "  plan        Plan terraform"
	@echo "  apply       Apply terraform"
	@echo "  destroy     Destroy terraform"

plan:
	terraform plan -var-file=environments/$(WORKSPACE).tfvars

apply:
	terraform apply -var-file=environments/${WORKSPACE}.tfvars

destroy:
	terraform destroy -var-file=environments/${WORKSPACE}.tfvars

init:
	@echo "Initializing terraform"
	terraform init

	@echo "Creating S3 bucket and DynamoDB table for terraform state"
	@aws s3api create-bucket --bucket $(SERVICE_NAME)-state-bucket \
		--region $(REGION) --create-bucket-configuration LocationConstraint=$(REGION)
	@aws dynamodb create-table \
		--table-name $(SERVICE_NAME)-terraform-lock-table \
		--attribute-definitions AttributeName=LockID,AttributeType=S \
		--key-schema AttributeName=LockID,KeyType=HASH \
		--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
		
	@echo "Storing credentials in AWS SSM"
	@aws ssm put-parameter --name "/$(SERVICE_NAME)/$(WORKSPACE)/db.username" \
	--value "$(SERVICE_NAME)_user" \
	--type "String"
	@aws ssm put-parameter --name "/$(SERVICE_NAME)/$(WORKSPACE)/db.password" \
	--value "$(shell openssl rand -base64 32 | tr -d /=+ | cut -c1-30)" \
	--type "SecureString"
	@aws ssm put-parameter --name "/$(SERVICE_NAME)/$(WORKSPACE)/wp.username" \
	--value "$(SERVICE_NAME)_admin" \
	--type "String"
	@aws ssm put-parameter --name "/$(SERVICE_NAME)/$(WORKSPACE)/wp.password" \
	--value "$(shell openssl rand -base64 32)" \
	--type "SecureString"

site-install:
	@echo "Installing WordPress..."
	ssh -i $(PEM_KEY_PATH) ec2-user@$(PUBLIC_IP) << EOF \
		docker exec -u www-data -i \
			-e WP_SITE_URL=\"http://$(PUBLIC_IP)\" \
			-e WP_SITE_TITLE=\"$(SERVICE_NAME) dev\" \
			-e WP_ADMIN_USER=\"$(SERVICE_NAME)_admin\" \
			-e WP_ADMIN_PASSWORD=\"$(WP_ADMIN_PASSWORD)\" \
			-e WP_ADMIN_EMAIL=\"dev+$(SERVICE_NAME)@johannez.com\" \
			-e WP_POST_URL_STRUCTURE=\"/%postname%/\" \
			demo /bin/bash -c "./scripts/site_install.sh" \
	EOF


