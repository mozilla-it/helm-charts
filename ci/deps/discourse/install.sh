#!/usr/bin/env bash

set -e

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

readonly NAMESPACE="chart-ci-e2e"



helm upgrade --install \
  --version 10.8.0 \
  --namespace $NAMESPACE \
  --set fullnameOverride=discourse-psql \
  --set persistence.enabled=false \
  --set postgresqlDatabase=discourse \
  --set postgresqlPassword=discourse-psql-password \
  --set postgresqlUsername=postgres \
  postgresql-discourse bitnami/postgresql



helm upgrade --install \
  --version 14.8.6 \
  --namespace $NAMESPACE \
  --set auth.enabled=true \
  --set auth.password=discourse-redis-password \
  --set fullnameOverride=discourse-redis \
  --set persistence.enabled=false \
  redis-discourse bitnami/redis
