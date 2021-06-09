#!/usr/bin/env bash

for d in ci/deps/*/; do
  echo $d
  if ls $d/*.sh 1> /dev/null 2>&1; then
    for f in $d/*.sh; do bash "$f" -H ; done
  fi
done
