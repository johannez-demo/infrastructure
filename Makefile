WORKSPACE := $(shell terraform workspace show)

plan:
	terraform plan -var-file=environments/$(WORKSPACE).tfvars

apply:
	terraform apply -var-file=environments/${WORKSPACE}.tfvars

destroy:
	terraform destroy -var-file=environments/${WORKSPACE}.tfvars
