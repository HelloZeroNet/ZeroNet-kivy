#!/bin/bash

# reset src
if [ -e .pre ]; then
  rm -rf src/zero
  git submodule update
  rm .pre
fi

# get version wrapper
zn_ver() {
  pushd src/zero/src

  lver=$(cat Config.py | grep "^[ ]*self.version" | grep "[0-9]*\.[0-9]*\.[0-9]*" -o)

  lat=$(git log --grep="Rev[0-9]*" --format="[%H] = %s" | head -n 1)
  lc=$(echo "$lat" | grep "\[[a-z0-9A-Z]*\]" -o | grep "[a-z0-9A-Z]*" -o)
  lrev=$(echo "$lat" | grep "Rev[0-9]*" -o)

  echo "commit = $lc / rev = $lrev / ver = $lver"

  popd
}

zn_ver
CMT_BEFORE="$lc"

# fetch new zn
git -C src/zero remote update -p
git -C src/zero merge --ff-only origin/master

zn_ver

if [ "$CMT_BEFORE" != "$lc" ]; then
  source .version.sh

  if [ "$CUR_VERSION" != "$lver" ]; then
    CUR_VERSION="$lver"
    VER_SUFFIX=1
    echo "Major upgrade, reset suffix"
  else
    VER_SUFFIX=$(( $VER_SUFFIX + 1 ))
    echo "Minor upgrade, suffix++"
  fi

echo '#!/bin/bash

CUR_VERSION="'"$CUR_VERSION"'

VER_SUFFIX='"$VER_SUFFIX"'' > .version.sh

  git commit -m "Update ZeroNet to $lrev" src/zero .version.sh
  git push

  echo DONE
fi
