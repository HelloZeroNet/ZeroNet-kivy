#!/bin/bash

cd release

F=()

for apk in *; do
  F+=(-F "apks=@$apk")
done

curl 'https://f-droid.mkg20001.io/1/' --compressed -H "$FDROID_TOKEN_1" -H "$FDROID_TOKEN_2" -H 'RM-Background-Type: apks' "${F[@]}"
