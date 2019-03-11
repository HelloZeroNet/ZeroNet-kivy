'use strict'

set -ev

# prepare
bash .ci/bind-cache.sh
export TERM=xterm-256color
export DISABLE_PROGRESS=1
# source .version.sh

replace_var() {
  sed -r "s|#* *$1 = .*|$1 = $2|g" -i buildozer.spec
}

disable_var() {
  sed -r "s|#* *$1 = .*|# $1 (disabled) = 0|g" -i buildozer.spec
}

if [ -z "$CI_COMMIT_TAG" ]; then # build a nightly
  replace_var package.domain luna.mkg20001
  replace_var title ZeroNetN
  # disable_var version.regex
  # disable_var version.filename
  # replace_var version "$CUR_VERSION.$(date +%s)"
  # SUFFIX=$(git log --oneline | wc -l | sed -r "s|(.+)([0-9]{2})|\1.\2|g") # turns commit count into version, e.g. 111 -> 1.11
  SUFFIX=$(git log --oneline | wc -l) # counts commits
  sed -r "s|VER_SUFFIX.+|VER_SUFFIX=$SUFFIX|g" -i .version.sh
fi

if [ ! -z "$MINTARGET" ]; then
  replace_var android.minapi "$MINTARGET"
  replace_var android.ndk_api "$MINTARGET"
fi

# setup
replace_var android.arch "$TARGET_ARCH"
echo -e "EXEC=docker\nDOCKER_IMAGE=$IMAGE_TAG\nDISABLE_PROGRESS=1" > .env
docker pull $IMAGE_TAG
bash ./tool.sh prebuild

# execute
script -q -e -c "make _ci"

# post-check
ls bin | grep debug | grep .apk # ensure job generated debug apk
ls bin | grep release | grep .apk # ensure job generated release apk
mkdir ci-out && mv bin ci-out/$CI_JOB_NAME && mv buildozer.spec ci-out/$CI_JOB_NAME/
