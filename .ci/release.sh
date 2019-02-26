#!/bin/bash

set -e

for arch_path in ci-out/*; do
  arch=$(basename "$arch_path")
  mkdir -p "release/$arch"

  # generate stripped spec file
  cat "$arch_path/buildozer.spec" | sed "s|^#.+||g" | grep -v "^\$" > "release/$arch/buildozer.spec"

  release_unaligned=$(echo "$arch_path/"*release-unsigned*)
  debug=$(echo "$arch_path/"*debug*)

  for f in "$release_unaligned" "$debug"; do
    fout=${f/".apk"/"$arch.apk"}
    mv -v "$f" "${fout}"
  done
done
