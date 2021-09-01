#!/usr/bin/env bash

set -e

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

readonly NAMESPACE="chart-ci-e2e"



helm upgrade --install \
  --version 10.4.2 \
  --namespace $NAMESPACE \
  --set postgresqlPassword=defaultpassword \
  --set postgresqlUsername=careers \
  --set postgresqlDatabase=careers \
  --set fullnameOverride=careers-psql \
  careers-psql bitnami/postgresql
