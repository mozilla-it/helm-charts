#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly REPO_ROOT=$(git rev-parse --show-toplevel)

readonly CHARTS_DIR="${REPO_ROOT}/charts"
readonly RELEASES_DIR="${REPO_ROOT}/releases"

mkdir -p "${RELEASES_DIR}"

cd "${CHARTS_DIR}"
for i in $(find . -maxdepth 1 -mindepth 1 -type d) ; do
    helm lint "${i}"
    helm dependency update "${i}"
    helm package "${i}" -d "${RELEASES_DIR}"
done
cd ..

git checkout gh-pages
mv ./*.tgz "${RELEASES_DIR}"
cd "${RELEASES_DIR}"
helm repo index --url https://mozilla-it.github.io/helm-charts/ --merge ../index.yaml .
