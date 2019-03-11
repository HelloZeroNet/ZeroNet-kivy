#!/bin/bash

mkdir release

UPCMD=$(echo "$NIGHTLY_UPCMD" | base64 -d)

for f in package/unsigned/*.apk; do
  OUT=${f/"package/unsigned/"/"release/"}
  OUT=${OUT/"-unsigned"/"-nightly"}
  curl 172.17.0.1:6234 --header "Token: $NIGHTLY_SIGNING_TOKEN" -F "apk=@$f" -o "$OUT"
done
