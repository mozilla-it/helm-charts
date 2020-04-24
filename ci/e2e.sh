#!/bin/bash

readonly REPO_ROOT=$(git rev-parse --show-toplevel)
readonly FUNCTIONS="${REPO_ROOT}/ci/functions.sh"
readonly CLUSTER_NAME="${CLUSTER_NAME:-kind}"
readonly CONFIG_FILE="${REPO_ROOT}/ci/kind.yaml"

# shellcheck source=ci/functions.sh
[ -f "${FUNCTIONS}" ] && source "${FUNCTIONS}" || exit 1

create_kind_cluster() {
    echo 'Installing kind ..'

    kind create cluster \
        --name "${CLUSTER_NAME}" \
        --config "${CONFIG_FILE}" \
        --wait 60s

    configure_kube

    kubectl cluster-info
    echo

    kubectl get nodes
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
    docker_exec ct install
    echo
}

main() {
    run_ct_container
    trap cleanup EXIT

    create_kind_cluster
    install_charts
}

main
