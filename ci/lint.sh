#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

DEFAULT_IMAGE=quay.io/helmpack/chart-testing:v3.0.0-rc.1

main() {
    local image="$DEFAULT_IMAGE"
    local changed

    run_ct_container
    trap cleanup EXIT

    # Future proofing for github actions
    changed=$(docker_exec ct list-changed)
    if [[ -z "$changed" ]]; then
        echo 'No chart changes detected.'
        echo "::set-output name=changed::false"
        return
    fi

    # Convenience output for other actions to make use of ct config to check if
    # charts changed.
    echo "::set-output name=changed::true"

    lint
}

run_ct_container() {
    echo 'Running ct container...'
    local args=(run --rm --interactive --detach --network host --name ct "--volume=$(pwd)/ci/ct.yaml:/etc/ct/ct.yaml" "--volume=$(pwd):/workdir" "--workdir=/workdir")

    args+=("$image" cat)

    docker "${args[@]}"
    echo
}

cleanup() {
    echo 'Removing ct container...'
    docker kill ct > /dev/null 2>&1
    echo 'Done!'
}

docker_exec() {
    docker exec --interactive ct "$@"
}

lint() {
    echo "Linting chart..."
    docker_exec ct lint
    echo "Done"
}

main
