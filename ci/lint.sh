#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly REPO_ROOT=$(git rev-parse --show-toplevel)
readonly FUNCTIONS="${REPO_ROOT}/ci/functions.sh"

# shellcheck source=ci/functions.sh
[ -f "${FUNCTIONS}" ] && source "${FUNCTIONS}" || exit 1

main() {

    run_ct_container
    trap cleanup EXIT

    echo "Linting chart..."
    docker_exec ct lint
}

main
