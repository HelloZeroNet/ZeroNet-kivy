#!/bin/bash

# Config

ADB_FLAG=-d
VER_SUFFIX=1

# Vars

[ -z "$UID" ] && UID=$(id -u)
[ -z "$PWD" ] && PWD="$PWD"

bold=$(tput bold)
normal=$(tput sgr0)
RED=$(tput setaf 1)
NC="$normal" # No Color

# Executors

exec_docker() {
  docker run -u "$UID" --rm --privileged=true -it -v "$PWD:/home/data" -v "$HOME/.buildozer:/home/.buildozer" -v "$HOME/.android:/home/.android" "$docker_image" sh -c "echo builder:x:$UID:27:Builder:/home:/bin/bash | tee /etc/passwd > /dev/null && cd /home/data && $*"
}

exec_host() {
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
    cd src/zero && cp src/Config.py src/Config.py_ && sed -r "s|self\.version = ['\"](.*)['\"]|self.version = \"\1.$SUFFIX\"|g" -i src/Config.py
    touch .pre
    ;;
  docker-build)
    make docker-build
    ;;
  *)
    die "No command specified! Use '$0 {setup, env, exec, docker-build, prebuild}'"
    ;;
esac
