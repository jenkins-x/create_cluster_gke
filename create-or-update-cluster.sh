#!/bin/bash

set -eu 

TERRAFORM_VERSION=0.11.7

function install_dependencies() {
	wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
	rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
}

function configure_environment() {
	echo $GKE_SA_JSON > ~/.gke_sa.json
}

function apply_terraform() {
	./terraform init
	./terraform plan -var 'credentials=~/.gke_sa.json'
	./terraform apply -var 'credentials=~/.gke_sa.json' -auto-approve
}

install_dependencies
configure_environment
apply_terraform
