#!/bin/bash

# Config

ADB_FLAG=-d
source .version.sh

# Vars

[ -z "$UID" ] && UID=$(id -u)
[ -z "$PWD" ] && PWD="$PWD"

bold=$(tput bold)
normal=$(tput sgr0)
RED=$(tput setaf 1)
NC="$normal" # No Color

# Executors

exec_docker() {
  docker run -u "$UID" --rm --privileged=true -it -e "APP_ALLOW_MISSING_DEPS=true" -e "USE_SDK_WRAPPER=1" -v "$PWD:/home/data" -v "$HOME/.gradle:/home/.gradle" -v "$HOME/.buildozer:/home/.buildozer" -v "$HOME/.android:/home/.android" "$docker_image" sh -c "echo builder:x:$UID:27:Builder:/home:/bin/bash | tee /etc/passwd > /dev/null && cd /home/data && $*"
}

exec_host() {
  export USE_SDK_WRAPPER=1
  export APP_ALLOW_MISSING_DEPS=true
  "$@"
}

_exec() {
  [ -z "$*" ] && die "No command passed to exec!"
  debug "EXEC $EXEC, CMD $*"
  "exec_$EXEC" "$@"
}

debug() {
  [ ! -z "$DEBUG" ] && echo "${bold}DEBUG${NC}: $*"
}

info() {
  echo "${bold}[INFO]${NC}: $*"
}

menu() {
  a=($1) # arrayify
  i=0
  for c in $1; do # show list
    echo -n "[$i] $c"
    [ "$i" == "0" ] && echo " (recommended)" || echo
    i=$(expr $i + 1)
  done
  read -p "> " id # prompt user
  res="${a[$id]}"
  [ -z "$res" ] && echo "Invalid ID: $id" && menu "$1" && return 0
  echo "< $res"
}

error() {
  echo "${RED}${bold}[ERROR]${NC}: $*"
}

die() {
  error "$*"
  exit 2
}

# Scripts

mkenv() {
  info "Running 'make env'"
  set +e
  make -C env
}

getmeta() {
  cat src/zero/src/Config.py | grep "$1 =" | sed -r "s|(.*) = ||g"
}

# Main Code

if [ "$1" == "_getvar" ]; then
  [ -e .env ] && source .env && echo "${!2}"
  exit 0
fi

[ ! -e .env ] && [ "$1" != "setup" ] && die "No .env file found! Run '$0 setup'"

source .env

docker_image="$DOCKER_IMAGE"

debug "EXEC=$EXEC"
debug "docker_image=$docker_image"

case "$1" in
  setup)
    echo "How should buildozer/kivy be executed?"
    menu "docker host"
    echo "EXEC=$res" > .env
    case "$res" in
      docker)
        echo "Which image should be used?"
        echo "(The 'kivy' image should only be used if you are building the image yourself using '$0 docker-build')"
        menu "mkg20001/zeronet-kivy:latest kivy"
        echo "DOCKER_IMAGE=$res" >> .env
        [ "$res" != "kivy" ] && docker pull "$res"
        ;;
      host)
        echo "Please run 'make host-deps' to complete the setup"
        echo "(This will install all needed packages and tools)"
        exit 2
        ;;
    esac
    ;;
  env)
    mkenv
    ;;
  exec)
    shift
    _exec "$@"
    ;;
  prebuild)
    if [ -e .pre ]; then rm -rf src/zero && git submodule update; fi
    V=$(echo $(cat src/zero/src/Config.py | grep self.version | sed -r "s|self\.version = ['\"](.*)['\"]|\1|g" | head -n 1))
    if [ "$V" != "$CUR_VERSION" ]; then echo ".version.sh \$VER_SUFFIX needs to be reset, major version change: $CUR_VERSION != $V" && exit 2; fi
    cd src/zero && cp src/Config.py src/Config.py_ && sed -r "s|self\.version = ['\"](.*)['\"]|self.version = \"\1.$VER_SUFFIX\"|g" -i src/Config.py
    cd ../../
    touch .pre
    ;;
  metadata)
    echo "{\"rev\":$(getmeta self.rev),\"ver\":$(getmeta self.version),\"date\":$(expr $(date +%s) \* 1000)}" > bin/release/metadata.json
    ;;
  post-sign)
    cp -v bin/release/{ZeroNet.apk,metadata.json} $HOME/ZeroNet/data/1A9gZwjdcTh3bpdriaWm7Z4LNdUL8GhDu2
    ;;
  docker-build)
    make docker-build
    ;;
  *)
    die "No command specified! Use '$0 {setup, env, exec, docker-build, prebuild}'"
    ;;
esac
