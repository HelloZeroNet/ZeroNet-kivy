#!/bin/bash

for f in package/*release*.apk; do
  OUT=${f/"package/"/"release/"}
  curl 172.17.0.1:6234 --header "Token: $NIGHTLY_SIGNING_TOKEN" -F "apk=@$f" -o "$OUT"
done

# TODO: push to repo
