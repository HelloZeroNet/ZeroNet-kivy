#!/bin/bash

set -e

create_and_chmod() {
  mkdir -p "$1"
  sudo chmod 777 "$1"
}

bind_folder() {
  LOCAL="$1/$2"
  CACHE="/cache/kivy/$2"

  echo "[CACHE] Bind $LOCAL to $CACHE"
  rm -rf "$LOCAL"
  create_and_chmod "$(dirname "$LOCAL")"
  create_and_chmod "$CACHE"
  # sudo mount --bind "$CACHE" "$LOCAL"
  sudo ln -s "$CACHE" "$LOCAL"
}

bind_folder "$HOME" .buildozer/android
bind_folder "$HOME" .gradle
bind_folder "$HOME" .android
