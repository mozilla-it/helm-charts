#!/bin/bash

# setups test with required packages

set -o errexit
set -o nounset
set -o pipefail

KIND_VERSION=v0.7.0
HELM_VERSION=v3.2.0

echo "=== Install kubectl"
sudo curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && sudo chmod +x /usr/local/bin/kubectl

echo "=== Install helm"
curl -L "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar xz && sudo mv linux-amd64/helm /bin/helm && sudo rm -rf linux-amd64

echo "=== Install kind ${KIND_VERSION}"
curl -sSLo kind "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-linux-amd64" && chmod +x kind && sudo mv kind /usr/local/bin/kind

echo "=== Install awscli"
pip install --user awscli

