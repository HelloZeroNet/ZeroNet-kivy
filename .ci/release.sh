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
    fout=${f/".apk"/"-$arch.apk"}
    fout=$(basename "$fout")
    fout="release/$fout"
    mv -v "$f" "${fout}"
  done
done

getmeta() {
  cat src/zero/src/Config.py | grep "$1 =" | sed -r "s|(.*) = ||g"
}

echo "{\"rev\":$(getmeta self.rev),\"ver\":$(getmeta self.version),\"date\":$(expr $(date +%s) \* 1000)}" > release/metadata.json
