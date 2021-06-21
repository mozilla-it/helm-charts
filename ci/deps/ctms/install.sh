#!/usr/bin/env bash

set -e

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

readonly NAMESPACE="chart-ci-e2e"



helm upgrade --install \
  --version 10.4.2 \
  --namespace $NAMESPACE \
  --set postgresqlPassword=defaultpassword \
  --set postgresqlUsername=ctms \
  --set postgresqlDatabase=ctms \
  --set fullnameOverride=postgres \
  postgresql bitnami/postgresql
