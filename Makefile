MODULES = golden_image instances network

.PHONY: docs init plan-create plan-destroy exec-plan apply destroy clean-up ssh-key ssh-bastion tests

all: help

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  help: show this help"
	@echo "  docs: generate or update the documentation on each module"
	@echo "  init: initialize terraform"
	@echo "  validate: validate terraform files"
	@echo "  show: show terraform state"
	@echo "  output: show terraform output"
	@echo "  plan-create: create a plan to create the environment"
	@echo "  plan-destroy: create a plan to destroy the environment"
	@echo "  exec-plan: execute the plan created either to create or destroy the environment"
	@echo "  apply: init plan-create exec-plan : single command to create the environment"
	@echo "  destroy: plan-destroy exec-plan : single command to destroy the environment"
	@echo "  clean-up: destroy : destroy the environment and remove local files"
	@echo "  ssh-key: generate ssh key file to be used to connect to the instances"
	@echo "  ssh-bastion: ssh to bastion host"
	@echo "  tests: run connectivity tests to the bastion and from the bastion to the private instances"

docs:
	terraform-docs markdown . -c .terraform-docs.yml
	for module in $(MODULES); do \
		terraform-docs markdown modules/$$module -c .terraform-docs.yml; \
	done; \
	cp README.md docs/README.md; \
  for module in $(MODULES); do \
		cp modules/$$module/README.md docs/module_$$module.md; \
	done


init:
	terraform init

validate:
	terraform validate

refresh:
	terraform refresh

show: refresh
	terraform show

output:
	terraform output

plan-create:
	terraform plan -var-file=terraform.tfvars -out=terraform.tfplan

plan-destroy:
	terraform plan -var-file=terraform.tfvars -destroy -out=terraform.tfplan

exec-plan:
	terraform apply terraform.tfplan

apply: init plan-create exec-plan

destroy: plan-destroy exec-plan

clean-up: destroy
	rm -rf .terraform
	rm -f .terraform.lock.hcl terraform.tfplan key.pem resources/*.json resources/*.out

ssh-key:
	terraform output -raw SSH_key_content > key.pem
	chmod 600 key.pem

ssh-bastion: ssh-key
	ssh -i key.pem -l ubuntu $(shell terraform output -raw Bastion_Host_IP)

tests: ssh-key
	nc -zv $(shell terraform output -raw Bastion_Host_IP) 22
	nc -vz $(shell terraform output -raw Load_blanacer_HTTP_Content) 80
	curl -si http://$(shell terraform output -raw Load_blanacer_HTTP_Content)
	ssh -o  BatchMode=yes -i key.pem -l ubuntu $(shell terraform output -raw Bastion_Host_IP) "cd /home/ubuntu && ./tests.sh $(shell terraform output -json Private_instances_IP_addresses | jq -r '.[]' | tr '\n' ' ')"
