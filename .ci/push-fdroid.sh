#!/bin/bash

set -e

cd release

CMD=$(echo "$FDROID_UPLOAD" | base64 -d)

eval $CMD
