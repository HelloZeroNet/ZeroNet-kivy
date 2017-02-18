#!/bin/sh

mir="http://archive.ubuntu.com"
url="$mir/ubuntu/pool/universe/v/vagrant/"

file_=$(curl $url --silent | grep "vagrant_[0-9.+a-z_-]*" -o | awk '!x[$0]++' | grep "deb$" | sort -r | head -n 1)
file="$url$file_"

o="vagrant.deb"

set -x

wget $file -O $o
dpkg -i -f $o
apt-get -f install
