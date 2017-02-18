#!/bin/sh

url="https://releases.hashicorp.com/vagrant/1.9.1/vagrant_1.9.1_x86_64.deb"

o="vagrant.deb"

set -x

wget $file -O $o
dpkg -i --force-all $o
apt-get -f install
