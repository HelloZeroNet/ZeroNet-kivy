#!/bin/bash

# test: mkdir -p ci-out/{a,b,c} && touch ci-out/{a,b,c}/{buildozer.spec,test-{release-unsigned,debug}.apk} && for f in ci-out/*/buildozer.spec; do echo -e "# test\ntest\n\n" > "$f"; done

set -e

mkdir -p package/{unsigned,debug,spec}

for arch_path in ci-out/*; do
  arch=$(basename "$arch_path")

  # generate stripped spec file
  cat "$arch_path/buildozer.spec" | sed "s|^#.+||g" | grep -v "^\$" > "package/spec/buildozer.$arch.spec"

  # get apks
  release_unsigned=$(echo "$arch_path/"*release-unsigned*)
  debug=$(echo "$arch_path/"*debug*)

  # move apks
  for f in "$release_unsigned" "$debug"; do
    outfolder=$(echo "$f" | sed -r "s|.+-([a-z-]+).apk|\1|g")
    fout=${f/".apk"/"-$arch.apk"}
    fout=$(basename "$fout")
    fout="package/$outfolder/$fout"
    mv -v "$f" "${fout}"
  done
done

getmeta() {
  cat src/zero/src/Config.py | grep "$1 =" | sed -r "s|(.*) = ||g"
}

echo "{\"rev\":$(getmeta self.rev),\"ver\":$(getmeta self.version),\"date\":$(expr $(date +%s) \* 1000)}" > package/metadata.json
