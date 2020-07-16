#!/bin/bash

readonly REPO_ROOT=$(git rev-parse --show-toplevel)
readonly FUNCTIONS="${REPO_ROOT}/ci/functions.sh"
readonly CLUSTER_NAME="${CLUSTER_NAME:-kind}"
readonly CONFIG_FILE="${REPO_ROOT}/ci/kind.yaml"
readonly NAMESPACE="chart-ci-e2e"

# shellcheck source=ci/functions.sh
[ -f "${FUNCTIONS}" ] && source "${FUNCTIONS}" || exit 1

create_kind_cluster() {
    echo 'Installing kind ..'

    kind create cluster \
        --name "${CLUSTER_NAME}" \
        --config "${CONFIG_FILE}" \
        --wait 60s
}

configure_kind_cluster() {
    configure_kube

    kubectl cluster-info
    echo

    kubectl get nodes
    echo
    
    if [[ $(kubectl get namespaces | grep -w $NAMESPACE) ]] ; then
        # If the NS exists, delete it and recreate it to get a clean state
        kubectl delete namespace $NAMESPACE
        kubectl create namespace $NAMESPACE
    else
        kubectl create namespace $NAMESPACE
    fi
    echo

    echo 'Cluster ready..'
    echo
}

configure_kube() {

    kind get kubeconfig > kind.config

    echo 'Copying kubeconfig to container'
    docker_exec sh -c 'mkdir -p /root/.kube'
    docker cp kind.config ct:/root/.kube/config
    echo
}

install_charts() {
    echo 'Installing charts...'
    docker_exec ct install --namespace $NAMESPACE
    echo
}

check_cluster_exists () {
    # 0 if cluster already exists
    kind get clusters | grep -q -w "$CLUSTER_NAME"
    echo $?
}

create_ecr_secret () {
    # Gets a valid token to pull from ECR and creates a secret with it
    ACCOUNT=$(aws sts get-caller-identity --output text --query Account)
    REGION=us-west-2
    SECRET_NAME=ecr-registry
    EMAIL=itse@mozilla.com

    # Fetch token (which will expire in 12 hours)
    TOKEN=$(aws ecr --region=$REGION get-authorization-token --output text --query authorizationData[].authorizationToken | base64 -d | cut -d: -f2)

    # Create or replace secret
    kubectl delete secret -n $NAMESPACE --ignore-not-found "$SECRET_NAME"
    kubectl create secret -n $NAMESPACE docker-registry "$SECRET_NAME" \
     --docker-server="https://${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com" \
     --docker-username=AWS \
     --docker-password="${TOKEN}" \
     --docker-email="${EMAIL}"
}

main() {
    run_ct_container
    trap cleanup EXIT

    if [[ $(check_cluster_exists) != 0 ]] ; then
        create_kind_cluster
    fi

    configure_kind_cluster
    create_ecr_secret
    install_charts
}

main
