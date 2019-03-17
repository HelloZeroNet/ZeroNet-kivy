#!/bin/bash

mkdir release

UPCMD=$(echo "$NIGHTLY_UPCMD" | base64 -d)

for f in package/unsigned/*.apk; do
  OUT=${f/"package/unsigned/"/"release/"}
  OUT=${OUT/"-unsigned"/"-nightly"}

  rm -f /tmp/zn-release.apk
  zipalign -v -p 4 "$f" /tmp/zn-release.apk

  curl 172.17.0.1:6234 --header "Token: $NIGHTLY_SIGNING_TOKEN" -F "apk=@/tmp/zn-release.apk" -o "$OUT"

  if [ ! -s "$OUT" ]; then
    echo "ERR: Signing failed" >&2
    exit 2
  fi
done
