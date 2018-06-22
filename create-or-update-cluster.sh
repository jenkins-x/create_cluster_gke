#!/bin/bash

set -eu 

TERRAFORM_VERSION=0.11.7
GIT_NAME="jenkins-x-bot"
GIT_EMAIL="jenkins-x@googlegroups.com"
STATE_REPO="https://$GIT_TOKEN:x-oauth-basic@github.com/rawlingsj/create_cluster_gke_state.git"

function install_dependencies() {
	wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
	rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
}

function configure_environment() {
	echo $GKE_SA_JSON > ~/.gke_sa.json
	git config --global user.email "${GIT_EMAIL}"
	git config --global user.name "${GIT_NAME}"
	git clone ${STATE_REPO} ../create_cluster_gke_state
}

function apply_terraform() {
	./terraform init
	./terraform plan -var 'credentials=~/.gke_sa.json'
	./terraform apply -var 'credentials=~/.gke_sa.json' -auto-approve -state=../create_cluster_gke_state/terraform.tfstate
}

function commit_state() {
	cd ../create_cluster_gke_state
	git add --all
	git commit -a -m 'state update'
	git push origin master
}

install_dependencies
configure_environment

# incase of failure, always commit state
trap "commit_state" EXIT
apply_terraform
