#!/bin/bash

set -e

create_and_chmod() {
  mkdir -p "$1"
  sudo chmod 777 "$1"
}

bind_folder() {
  LOCAL="$HOME/$1"
  CACHE="/cache/kivy/$1"

  echo "[CACHE] Bind $LOCAL to $CACHE"
  create_and_chmod "$LOCAL"
  create_and_chmod "$CACHE"
  sudo mount --bind "$LOCAL" "$CACHE"
}

bind_folder .buildozer/android
bind_folder .gradle
