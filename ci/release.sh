#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

mkdir release

cd charts
for i in $(find . -maxdepth 1 -mindepth 1 -type d) ; do
    helm lint $i
    helm dependency update $i
    helm package $i -d ../releases
done
cd ..

git checkout gh-pages
mv *.tgz releases/
helm repo index --url https://mozilla-it.github.io/helm-charts/ --merge ../index.yaml .
